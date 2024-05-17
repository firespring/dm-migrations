require_relative '../../spec_helper'

describe 'SQL module' do
  describe 'TableCreator' do
    before do
      @adapter = instance_double('adapter')
      allow(@adapter).to receive(:quote_name).and_return(%('users'))
      @tc = SQL::TableCreator.new(@adapter, 'users') { }
    end

    describe 'initialization' do
      it 'sets @adapter to the adapter' do
        expect(@tc.instance_variable_get('@adapter')).to eq @adapter
      end

      it 'sets @table_name to the stringified table name' do
        expect(@tc.instance_variable_get('@table_name')).to eq 'users'
      end

      it 'sets @opts to the options hash' do
        expect(@tc.instance_variable_get('@opts')).to eq {}
      end

      it 'sets @columns to an empty array' do
        expect(@tc.instance_variable_get('@columns')).to eq []
      end

      it 'evaluates the given block' do
        block = proc { column :foo, :bar }
        col = instance_double('column')
        expect(SQL::TableCreator::Column).to receive(:new).with(@adapter, :foo, :bar, {}).and_return(col)
        tc = SQL::TableCreator.new(@adapter, 'users', {}, &block)
        expect(tc.instance_variable_get('@columns')).to eq [col]
      end
    end

    it 'has a table_name' do
      expect(@tc).to respond_to(:table_name)
      expect(@tc.table_name).to eq 'users'
    end

    it 'uses the adapter to quote the table name' do
      expect(@adapter).to receive(:quote_name).with('users').and_return(%('users'))
      expect(@tc.quoted_table_name).to eq %('users')
    end

    it 'initializes a new column and add it to the list of columns' do
      col = instance_double('column')
      expect(SQL::TableCreator::Column).to receive(:new).with(@adapter, :foo, :bar, {}).and_return(col)
      @tc.column(:foo, :bar)
      expect(@tc.instance_variable_get('@columns')).to eq [col]
    end

    it 'outputs an SQL CREATE statement to build itself' do
      allow(@adapter).to receive(:table_options).and_return('')
      expect(@tc.to_sql).to eq %{CREATE TABLE 'users' ()}
    end

    describe 'Column' do
      before do
        connection = instance_double('Connection')

        allow(@adapter).to receive(:quote_column_name).and_return(%('id'))
        allow(@adapter.class).to receive(:type_map).and_return(Integer => {type: 'int'})
        allow(@adapter.class).to receive(:type_by_property_class).and_return(Integer => {type: 'int'})
        allow(@adapter).to receive(:property_schema_statement).and_return('SOME SQL')
        allow(@adapter).to receive(:with_connection).and_yield(connection)
        @c = SQL::TableCreator::Column.new(@adapter, 'id', Integer, :serial => true)
      end

      describe 'initialization' do
        it 'sets @adapter to the adapter' do
          expect(@c.instance_variable_get('@adapter')).to eq @adapter
        end

        it 'sets @name to the stringified name' do
          expect(@c.instance_variable_get('@name')).to eq 'id'
        end

        # TODO make this really the type, not this sql bullshit
        it 'sets @type to the type' do
          expect(@c.instance_variable_get('@type')).to eq 'SOME SQL'
        end

        it 'sets @opts to the options hash' do
          expect(@c.instance_variable_get('@opts')).to eq({serial: true})
        end
      end
    end
  end
end
