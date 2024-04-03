require 'dm-migrations/sql/table'

require 'fileutils'

module SQL
  module Sqlite
    def supports_schema_transactions?
      true
    end

    def table(table_name)
      SQL::Sqlite::Table.new(self, table_name)
    end

    def recreate_database
      DataMapper.logger.info "Dropping #{@uri.path}"
      FileUtils.rm_f(@uri.path)
      # do nothing, sqlite will automatically create the database file
    end

    def table_options(_opts)
      ''
    end

    def supports_serial?
      true
    end

    def change_column_type_statement(*)
      raise NotImplementedError
    end

    def rename_column_type_statement(*)
      raise NotImplementedError
    end

    class Table < SQL::Table
      def initialize(adapter, table_name)
        super()
        @columns = []
        adapter.table_info(table_name).each do |col_struct|
          @columns << SQL::Sqlite::Column.new(col_struct)
        end
      end
    end

    class Column < SQL::Column
      def initialize(col_struct)
        super()
        @name = col_struct.name
        @type = col_struct.type
        @default_value = col_struct.dflt_value
        @primary_key = col_struct.pk

        @not_null = col_struct.notnull == 0
      end
    end
  end
end
