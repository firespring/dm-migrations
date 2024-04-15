require 'spec_helper'

describe 'The migration runner' do
  supported_by :postgres, :mysql, :sqlite, :oracle, :sqlserver do
    before(:all) do
      @adapter    = DataMapper::Spec.adapter
      @repository = DataMapper.repository(@adapter.name)
    end

    describe 'empty migration runner' do
      it 'should return an empty array if no migrations have been defined' do
        migrations.should be_kind_of(Array)
        migrations.size.should == 0
      end
    end

    describe 'migration runner' do
      # set up some 'global' setup and teardown tasks
      before(:each) do
        # FIXME: workaround because dm-migrations can only handle the :default repo
        # DataMapper::Repository.adapters[:default] =  DataMapper::Repository.adapters[adapter.to_sym]
        migration(1, :create_people_table) { nil }
      end

      after(:each) do
        migrations.clear
      end

      describe '#migration' do
        it 'should create a new migration object, and add it to the list of migrations' do
          expect(migrations).to be_kind_of(Array)
          expect(migrations.size).to eq 1
          expect(migrations.first.name).to eq 'create_people_table'
        end

        it 'should allow multiple migrations to be added' do
          migration(2, :add_dob_to_people) { nil }
          migration(2, :add_favorite_pet_to_people) { nil }
          migration(3, :add_something_else_to_people) { nil }
          migrations.size.should == 4
        end

        it 'should raise an error on adding with a duplicated name' do
          -> { migration(1, :create_people_table) { nil } }.should raise_error(RuntimeError, /Migration name conflict/)
        end
      end

      describe '#migrate_up! and #migrate_down!' do
        before(:each) do
          migration(2, :add_dob_to_people) { nil }
          migration(2, :add_favorite_pet_to_people) { nil }
          migration(3, :add_something_else_to_people) { nil }
        end

        it 'calling migrate_up! should migrate up all the migrations' do
          # add our expectation that migrate_up should be called
          migrations.each do |m|
            m.should_receive(:perform_up)
          end
          migrate_up!
        end

        it 'calling migrate_up! with an argument should only migrate to that level' do
          migrations.each do |m|
            if m.position <= 2
              m.should_receive(:perform_up)
            else
              m.should_not_receive(:perform_up)
            end
          end
          migrate_up!(2)
        end

        it 'calling migrate_down! should migrate down all the migrations' do
          # add our expectation that migrate_up should be called
          migrations.each do |m|
            m.should_receive(:perform_down)
          end
          migrate_down!
        end
      end
    end
  end
end
