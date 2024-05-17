require_relative '../spec_helper'

describe 'A Migration' do
  supported_by :postgres, :mysql, :sqlite, :oracle, :sqlserver do
    describe DataMapper::Migration, 'interface' do
      before(:all) do
        @adapter = DataMapper::Spec.adapter
      end

      before do
        @migration = DataMapper::Migration.new(1, :create_people_table, verbose: false) { nil }
      end

      before do
        @original = $stderr
        $stderr = StringIO.new
      end

      after do
        $stderr = @original
      end

      it 'has a position attribute' do
        expect(@migration).to respond_to(:position)

        expect(@migration.position).to eq 1
      end

      it 'has a name attribute' do
        expect(@migration).to respond_to(:name)

        expect(@migration.name).to eq :create_people_table
      end

      it 'has a :repository option' do
        m = DataMapper::Migration.new(2, :create_dogs_table, repository: :alternate) { nil }

        expect(m.instance_variable_get(:@repository)).to eq :alternate
      end

      it 'uses the default repository by default' do
        expect(@migration.instance_variable_get(:@repository)).to eq :default
      end

      it 'still supports a :database option' do
        m = DataMapper::Migration.new(2, :create_legacy_table, database: :legacy) { nil }

        expect(m.instance_variable_get(:@repository)).to eq :legacy
      end

      it 'warns when :database is used' do
        DataMapper::Migration.new(2, :create_legacy_table, database: :legacy) { nil }
        expect($stderr.string.chomp).to eq 'Using the :database option with migrations is deprecated, use :repository instead'
      end

      it 'has a verbose option' do
        m = DataMapper::Migration.new(2, :create_dogs_table, verbose: false) { nil }
        expect(m.instance_variable_get(:@verbose)).to eq false
      end

      it 'is verbose by default' do
        m = DataMapper::Migration.new(2, :create_dogs_table) { nil }
        expect(m.instance_variable_get(:@verbose)).to eq true
      end

      it 'is sortable, first by position, then name' do
        m1 = DataMapper::Migration.new(1, :create_people_table) { nil }
        m2 = DataMapper::Migration.new(2, :create_dogs_table) { nil }
        m3 = DataMapper::Migration.new(2, :create_cats_table) { nil }
        m4 = DataMapper::Migration.new(4, :create_birds_table) { nil }

        expect([m1, m2, m3, m4].sort).to eq [m1, m3, m2, m4]
      end

      adapter = DataMapper::Spec.adapter_name

      expected_module_lambda = {
        sqlite: -> { SQL::Sqlite },
        mysql: -> { SQL::Mysql },
        postgres: -> { SQL::Postgres }
      }[adapter.to_sym]

      expected_module = expected_module_lambda&.call

      if expected_module
        it "extends with #{expected_module} when adapter is #{adapter}" do
          migration = DataMapper::Migration.new(1, :"#{adapter}_adapter_test") { nil }
          expect((class << migration.adapter; self; end).included_modules).to include(expected_module)
        end
      end
    end

    describe DataMapper::Migration, 'defining actions' do
      before do
        @migration = DataMapper::Migration.new(1, :create_people_table, verbose: false) { nil }
      end

      it 'has an #up method' do
        expect(@migration).to respond_to(:up)
      end

      it 'saves the block passed into the #up method in @up_action' do
        action = -> {}
        @migration.up(&action)

        expect(@migration.instance_variable_get(:@up_action)).to eq action
      end

      it 'has a #down method' do
        expect(@migration).to respond_to(:down)
      end

      it 'saves the block passed into the #down method in @down_action' do
        action = -> {}
        @migration.down(&action)

        expect(@migration.instance_variable_get(:@down_action)).to eq action
      end

      it 'makes available an #execute method' do
        expect(@migration).to respond_to(:execute)
      end

      it 'makes available an #select method' do
        expect(@migration).to respond_to(:select)
      end

      it 'runs the sql passed into the #execute method'
      # TODO: Find out how to stub the DataMapper::database.execute method
    end

    describe DataMapper::Migration, 'output' do
      before do
        @migration = DataMapper::Migration.new(1, :create_people_table) { nil }
        @migration.stub!(:write) # so that we don't actually write anything to the console!
      end

      it "#say's a string with an indent" do
        expect(@migration).to receive(:write).with('   Foobar')
        @migration.say('Foobar', 2)
      end

      it "#say's with a default indent of 4" do
        expect(@migration).to receive(:write).with('     Foobar')
        @migration.say('Foobar')
      end

      it '#say_with_time the running time of a block' do
        expect(@migration).to receive(:write).with(/Block/)
        expect(@migration).to receive(:write).with(/-> \d+/)

        @migration.say_with_time('Block') { nil }
      end
    end
  end
end
