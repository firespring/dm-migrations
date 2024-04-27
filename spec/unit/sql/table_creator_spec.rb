require_relative '../../spec_helper'

describe 'SQL module' do
  describe 'TableCreator' do
    let(:adapter) { instance_double('adapter') }
    let(:table_name) { :users }
    let(:opts) { {} }
    let(:block) { {} }
    let(:col) { instance_double('column') }

    subject(:tc) { SQL::TableCreator.new(adapter, table_name, opts, &block) }

    before do
      allow(adapter).to receive(:quote_name).and_return(%{'users'})
    end

    describe 'initialization' do
      it 'should set @adapter to the adapter' do
        expect(tc.instance_variable_get("@adapter")).to eq adapter
      end

      it 'should set @table_name to the stringified table name' do
        expect(tc.instance_variable_get("@table_name")).to eq table_name.to_s
      end

      it 'should set @opts to the options hash' do
        expect(tc.instance_variable_get("@opts")).to eq opts
      end

      it 'should set @columns to an empty array' do
        expect(tc.instance_variable_get("@columns")).to eq []
      end

      context 'receives a block' do
        let(:block) { proc { column :foo, :bar } }
        let(:col) { double('column') }
        it 'should evaluate the given block' do
          expect(SQL::TableCreator::Column).to receive(:new).with(adapter, :foo, :bar, {}).and_return(col)
          expect(tc.instance_variable_get("@columns")).to eq [col]
        end
      end
    end

    it 'should have a table_name' do
      expect(tc).to respond_to(:table_name)
      expect(tc.table_name).to eq table_name.to_s
    end

    it 'should use the adapter to quote the table name' do
      expect(adapter).to receive(:quote_name).with('users').and_return(%{'users'})
      expect(tc.quoted_table_name).to eq %{'users'}
    end

    it 'should initialize a new column and add it to the list of columns' do
      expect(SQL::TableCreator::Column).to receive(:new).with(adapter, :foo, :bar, {}).and_return(col)
      tc.column(:foo, :bar)
      expect(tc.instance_variable_get("@columns")).to eq [col]
    end

    it 'should output an SQL CREATE statement to build itself' do
      allow(adapter).to receive(:table_options).and_return('')
      expect(tc.to_sql).to eq %{CREATE TABLE 'users' ()}
    end

    describe 'Column' do
      let(:opts) { {serial: true} }
      let(:connection) { instance_double('connection') }
      subject(:c) { SQL::TableCreator::Column.new(adapter, 'id', Integer, opts) }
      before do
        allow(adapter).to receive(:quote_column_name).and_return(%{'id'})
        allow(adapter.class).to receive(:type_map).and_return(Integer => {:type => 'int'})
        allow(adapter.class).to receive(:type_by_property_class).and_return(Integer => {:type => 'int'})
        allow(adapter).to receive(:property_schema_statement).and_return("SOME SQL")
        allow(adapter).to receive(:with_connection).and_yield(connection)
      end

      describe 'initialization' do
        it 'should set @adapter to the adapter' do
          expect(c.instance_variable_get("@adapter")).to eq adapter
        end

        it 'should set @name to the stringified name' do
          expect(c.instance_variable_get("@name")).to eq 'id'
        end

        # TODO make this really the type, not this sql bullshit
        it 'should set @type to the type' do
          expect(c.instance_variable_get("@type")).to eq 'SOME SQL'
        end

        it 'should set @opts to the options hash' do
          expect(c.instance_variable_get("@opts")).to eq opts
        end
      end
    end
  end
end
