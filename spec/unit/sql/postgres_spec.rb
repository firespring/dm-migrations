require_relative '../../spec_helper'

# a dummy class to include the module into
class PostgresExtension
  include SQL::Postgres
end

describe "Postgres Extensions" do
  subject(:pe) { PostgresExtension.new }

  let(:table) { double('Postgres Table') }

  it 'should support schema-level transactions' do
    expect(pe.supports_schema_transactions?).to be(true)
  end

  it 'should support the serial column attribute' do
    expect(pe.supports_serial?).to be(true)
  end

  it 'should create a table object from the name' do
    expect(SQL::Postgres::Table).to receive(:new).with(pe, 'users').and_return(table)

    expect(pe.table('users')).to eq table
  end

  describe 'recreating the database' do
  end

  describe 'Table' do
    subject(:t) { SQL::Postgres::Table.new(adapter, 'users') }
    let(:cs1) { double('Column Struct') }
    let(:cs2) { double('Column Struct') }
    let(:adapter) { instance_double('adapter', :select => []) }
    let(:col1) { double('Postgres Column') }
    let(:col2) { double('Postgres Column') }

    before do
      allow(adapter).to receive(:query_table).with('users').and_return([cs1, cs2])
    end

    it 'should initialize columns by querying the table' do
      expect(SQL::Postgres::Column).to receive(:new).with(cs1).and_return(col1)
      expect(SQL::Postgres::Column).to receive(:new).with(cs2).and_return(col2)
      expect(adapter).to receive(:query_table).with('users').and_return([cs1, cs2])
      t
    end

    it 'should create Postgres Column objects from the returned column structs' do
      expect(SQL::Postgres::Column).to receive(:new).with(cs1).and_return(col1)
      expect(SQL::Postgres::Column).to receive(:new).with(cs2).and_return(col2)
      t
    end

    it 'should set the @columns to the looked-up columns' do
      expect(SQL::Postgres::Column).to receive(:new).with(cs1).and_return(col1)
      expect(SQL::Postgres::Column).to receive(:new).with(cs2).and_return(col2)
      expect(t.columns).to eq [col1, col2]
    end

    describe '#query_column_constraints' do
    end
  end

  describe 'Column' do
    let(:cs) {
      double(
        'Struct',
        column_name: 'id',
        data_type: 'integer',
        column_default: 123,
        is_nullable: 'NO'
      )
    }
    let(:c) { SQL::Postgres::Column.new(cs) }

    it 'should set the name from the column_name value' do
      expect(c.name).to eq 'id'
    end

    it 'should set the type from the data_type value' do
      expect(c.type).to eq 'integer'
    end

    it 'should set the default_value from the column_default value' do
      expect(c.default_value).to eq 123
    end

    it 'should set not_null based on the is_nullable value' do
      expect(c.not_null).to eq true
    end
  end
end
