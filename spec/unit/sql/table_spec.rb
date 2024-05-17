require_relative '../../spec_helper'

describe SQL::Table do
  before do
    @table = SQL::Table.new
  end

  %w{name columns}.each do |meth|
    it "has a ##{meth} attribute" do
      expect(@table).to respond_to(meth.intern)
    end
  end

  it 'uses #to_s for the name' do
    @table.name = "table_name"
    expect(@table.to_s).to eq 'table_name'
  end

  it 'finds a column by name' do
    column_a = double('column', :name => 'id')
    column_b = double('column', :name => 'login')
    @table.columns = [column_a, column_b]

    expect(@table.column('id')).to eq column_a
  end
end
