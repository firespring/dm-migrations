require 'pathname'

dir = Pathname(__FILE__).dirname.expand_path

require "#{dir}sample_migration"
require "#{dir}../lib/spec/example/migration_example_group"

describe :create_people_table, type: :migration do
  before do
    run_migration
  end

  it 'should create a people table' do
    expect(repository(:default)).to have_table(:people)
  end

  it 'should have an id column as the primary key' do
    expect(table(:people)).to have_column(:id)
    expect(table(:people).column(:id).type).to eq 'integer'
    # table(:people).column(:id).should be_primary_key
  end

  it 'should have a name column as a string' do
    expect(table(:people)).to have_column(:name)
    expect(table(:people).column(:name).type).to eq 'character varying'
    expect(table(:people).column(:name)).to permit_null
  end

  it 'should have a nullable age column as a int' do
    expect(table(:people)).to have_column(:age)
    expect(table(:people).column(:age).type).to eq 'integer'
    expect(table(:people).column(:age)).to permit_null
  end
end

describe :add_dob_to_people, type: :migration do
  before do
    run_migration
  end

  it 'should add a dob column as a timestamp' do
    expect(table(:people)).to have_column(:dob)
    expect(table(:people).column(:dob).type).to eq 'timestamp without time zone'
    expect(table(:people).column(:dob)).to permit_null
  end
end
