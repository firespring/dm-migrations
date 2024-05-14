require_relative '../../spec_helper'

describe SQL::Column do
  before do
    @column = SQL::Column.new
  end

  %w{name type not_null default_value primary_key unique}.each do |meth|
    it "has a ##{meth} attribute" do
      expect(@column).to respond_to(meth.intern)
    end
  end

end
