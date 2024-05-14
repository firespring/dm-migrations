require_relative '../../spec_helper'

describe 'SQL module' do
  describe 'TableModifier' do
    let(:table_name) { :users }
    let(:opts) { {} }
    let(:adapter) { instance_double('adapter') }
    let(:block) { {} }
    let(:column) { instance_double('column') }

    subject(:tc) { SQL::TableModifier.new(adapter, table_name, opts, &block) }

    before do
      allow(adapter).to receive(:quote_name).and_return(%{'users'})
    end

    describe 'initialization' do
      it 'sets @adapter to the adapter' do
        expect(tc.instance_variable_get("@adapter")).to eq adapter
      end

      it 'sets @table_name to the stringified table name' do
        expect(tc.instance_variable_get("@table_name")).to eq 'users'
      end

      it 'sets @opts to the options hash' do
        expect(tc.opts).to eq opts
      end

      it 'sets @statements to an empty array' do
        expect(tc.instance_variable_get("@statements")).to eq []
      end

      context 'receives a block' do
        let(:block) { proc { column :foo, :bar } }
        let(:tc) { SQL::TableCreator.new(adapter, table_name, opts, &block) }

        it 'evaluates the given block' do
          expect(SQL::TableCreator::Column).to receive(:new).with(adapter, :foo, :bar, opts).and_return(column)
          expect(tc.instance_variable_get("@columns")).to eq [column]
        end
      end
    end

    it 'has a table_name' do
      expect(tc).to respond_to(:table_name)
      expect(tc.table_name).to eq 'users'
    end

    it 'uses the adapter to quote the table name' do
      expect(adapter).to receive(:quote_name).with('users').and_return(%{'users'})
      expect(tc.quoted_table_name).to eq %{'users'}
    end
  end
end
