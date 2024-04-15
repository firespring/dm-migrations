require 'dm-core'

module SQL
  class TableCreator
    extend DataMapper::Property::Lookup

    attr_accessor :table_name, :opts

    def initialize(adapter, table_name, opts = {}, &block)
      @adapter = adapter
      @table_name = table_name.to_s
      @opts = opts

      @columns = []

      instance_eval(&block)
    end

    def quoted_table_name
      @adapter.send(:quote_name, table_name)
    end

    def column(name, type, opts = {})
      @columns << Column.new(@adapter, name, type, opts)
    end

    def to_sql
      "CREATE TABLE #{quoted_table_name} (#{@columns.map(&:to_sql).join(', ')})#{@adapter.table_options(@opts)}"
    end

    # A helper for using the native NOW() SQL function in a default
    def now
      SqlExpr.new('NOW()')
    end

    # A helper for using the native UUID() SQL function in a default
    def uuid
      SqlExpr.new('UUID()')
    end

    class SqlExpr
      attr_accessor :sql

      def initialize(sql)
        @sql = sql
      end

      def to_s
        @sql.to_s
      end
    end

    class Column
      attr_accessor :name, :type

      def initialize(adapter, name, type, opts = {})
        @adapter = adapter
        @name = name.to_s
        @opts = opts
        @type = build_type(type)
      end

      def to_sql
        type
      end

      private def build_type(type_class)
        schema = {name: @name, quote_column_name: quoted_name}

        %i(nullable nullable?).each do |option|
          next if (value = schema.delete(option)).nil?

          warn "#{option.inspect} is deprecated, use :allow_nil instead"
          schema[:allow_nil] = value unless schema.key?(:allow_nil)
        end

        schema[:allow_nil] = !schema[:not_null] unless schema.key?(:allow_nil)

        if type_class.is_a?(String)
          schema[:primitive] = type_class
        else
          primitive = type_class.respond_to?(:dump_as) ? type_class.dump_as : type_class
          options   = @adapter.class.type_by_property_class(type_class) || @adapter.class.type_map[primitive]

          schema.update(type_class.options) if type_class.respond_to?(:options)
          schema.update(options)

          schema.delete(:length) if type_class <= DataMapper::Property::Text
        end

        schema.update(@opts)

        schema[:length] = schema.delete(:size) if schema.key?(:size)

        @adapter.send(:with_connection) do |connection|
          @adapter.property_schema_statement(connection, schema)
        end
      end

      private def quoted_name
        @adapter.send(:quote_name, name)
      end
    end
  end
end
