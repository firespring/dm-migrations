require_relative '../../spec_helper'

# a dummy class to include the module into
class PostgresExtension
  include SQL::Postgres
end

describe "Postgres Extensions" do
  before do
    @pe = PostgresExtension.new
  end

  it 'supports schema-level transactions' do
    expect(@pe.supports_schema_transactions?).to be(true)
  end

  it 'supports the serial column attribute' do
    expect(@pe.supports_serial?).to be(true)
  end

  it 'creates a table object from the name' do
    table = instance_double('Postgres Table')
    expect(SQL::Postgres::Table).to receive(:new).with(@pe, 'users').and_return(table)

    expect(@pe.table('users')).to eq table
  end

  describe 'recreating the database'

  describe 'Table' do
    before do
      @cs1 = instance_double('Column Struct')
      @cs2 = instance_double('Column Struct')
      @adapter = instance_double('adapter', select: [])
      allow(@adapter).to receive(:query_table).with('users').and_return([@cs1, @cs2])

      @col1 = instance_double('Postgres Column')
      @col2 = instance_double('Postgres Column')
    end

    it 'initializes columns by querying the table' do
      expect(SQL::Postgres::Column).to receive(:new).with(@cs1).and_return(@col1)
      expect(SQL::Postgres::Column).to receive(:new).with(@cs2).and_return(@col2)
      expect(@adapter).to receive(:query_table).with('users').and_return([@cs1,@cs2])
      SQL::Postgres::Table.new(@adapter, 'users')
    end

    it 'creates Postgres Column objects from the returned column structs' do
      expect(SQL::Postgres::Column).to receive(:new).with(@cs1).and_return(@col1)
      expect(SQL::Postgres::Column).to receive(:new).with(@cs2).and_return(@col2)
      SQL::Postgres::Table.new(@adapter, 'users')
    end

    it 'sets the @columns to the looked-up columns' do
      expect(SQL::Postgres::Column).to receive(:new).with(@cs1).and_return(@col1)
      expect(SQL::Postgres::Column).to receive(:new).with(@cs2).and_return(@col2)
      t = SQL::Postgres::Table.new(@adapter, 'users')
      expect(t.columns).to eq [@col1, @col2]
    end

    describe '#query_column_constraints'
  end

  describe 'Column' do
    before do
      @cs = instance_double('Struct',
                            column_name: 'id',
                            data_type: 'integer',
                            column_default: 123,
                            is_nullable: 'NO')
      @c = SQL::Postgres::Column.new(@cs)
    end

    it 'sets the name from the column_name value' do
      expect(@c.name).to eq 'id'
    end

    it 'sets the type from the data_type value' do
      expect(@c.type).to eq 'integer'
    end

    it 'sets the default_value from the column_default value' do
      expect(@c.default_value).to eq 123
    end

    it 'sets not_null based on the is_nullable value' do
      expect(@c.not_null).to eq true
    end
  end
end
