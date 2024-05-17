require_relative '../spec_helper'

# Column type is expected to be inherited from DataMapper::Property::Text (CLOB, TEXT or whatever)
class MyCustomProperty < DataMapper::Property::Text; end

describe 'SQL generation' do
  supported_by :postgres, :mysql, :sqlite, :oracle, :sqlserver do
    describe DataMapper::Migration, '#create_table helper' do
      before :all do
        @adapter    = DataMapper::Spec.adapter
        @repository = DataMapper.repository(@adapter.name)

        case DataMapper::Spec.adapter_name.to_sym
        when :sqlite
          @adapter.extend(SQL::Sqlite)
        when :mysql
          @adapter.extend(SQL::Mysql)
        when :postgres
          @adapter.extend(SQL::Postgres)
        end
      end

      before do
        @creator = DataMapper::Migration::TableCreator.new(@adapter, :people) do
          column :id,          DataMapper::Property::Serial
          column :name,        'VARCHAR(50)', allow_nil: false
          column :long_string, String, size: 200
          column :very_custom, MyCustomProperty
        end
      end

      it 'has a #create_table helper' do
        @migration = DataMapper::Migration.new(1, :create_people_table, verbose: false) { nil }
        expect(@migration).to respond_to(:create_table)
      end

      it 'has a table_name' do
        expect(@creator.table_name).to eq 'people'
      end

      it 'has an adapter' do
        expect(@creator.instance_eval('@adapter', __FILE__, __LINE__)).to eq @adapter
      end

      it 'has an options hash' do
        expect(@creator.opts).to be_kind_of(Hash)
        expect(@creator.opts).to eq({})
      end

      it 'has an array of columns' do
        expect(@creator.instance_eval('@columns', __FILE__, __LINE__)).to be_kind_of(Array)
        expect(@creator.instance_eval('@columns', __FILE__, __LINE__).size).to eq 4
        expect(@creator.instance_eval('@columns', __FILE__, __LINE__).first).to be_kind_of(DataMapper::Migration::TableCreator::Column)
      end

      it 'quotes the table name for the adapter' do
        expect(@creator.quoted_table_name).to eq((DataMapper::Spec.adapter_name.to_sym == :mysql) ? '`people`' : '"people"')
      end

      it 'allows for custom options' do
        columns = @creator.instance_eval('@columns', __FILE__, __LINE__)
        col = columns.detect { |c| c.name == 'long_string' }
        expect(col.instance_eval('@type', __FILE__, __LINE__)).to include('200')
      end

      it 'generates a NOT NULL column when :allow_nil is false' do
        expect(@creator.instance_eval('@columns', __FILE__, __LINE__)[1].type).to match(/NOT NULL/)
      end

      case DataMapper::Spec.adapter_name.to_sym
      when :mysql
        it 'creates an InnoDB database for MySQL' do
          # can't get an exact == comparison here because character set and collation may differ per connection
          expect(@creator.to_sql).to match(/^CREATE TABLE `people` \(`id` SERIAL PRIMARY KEY, `name` VARCHAR\(50\) NOT NULL, `long_string` VARCHAR\(200\), `very_custom` TEXT\) ENGINE = InnoDB CHARACTER SET \w+ COLLATE \w+\z/)
        end

        it 'allows for custom table creation options for MySQL' do
          opts = {
            storage_engine: 'MyISAM',
            character_set: 'big5',
            collation: 'big5_chinese_ci'
          }

          creator = DataMapper::Migration::TableCreator.new(@adapter, :people, opts) do
            column :id, DataMapper::Property::Serial
          end

          expect(creator.to_sql).to match(/^CREATE TABLE `people` \(`id` SERIAL PRIMARY KEY\) ENGINE = MyISAM CHARACTER SET big5 COLLATE big5_chinese_ci\z/)
        end

        it 'respects default storage engine types specified by the MySQL adapter' do
          adapter = DataMapper::Spec.adapter
          adapter.extend(SQL::Mysql)

          adapter.storage_engine = 'MyISAM'

          creator = DataMapper::Migration::TableCreator.new(adapter, :people) do
            column :id, DataMapper::Property::Serial
          end

          expect(creator.to_sql).to match(/^CREATE TABLE `people` \(`id` SERIAL PRIMARY KEY\) ENGINE = MyISAM CHARACTER SET \w+ COLLATE \w+\z/)
        end

      when :postgres
        it 'outputs a CREATE TABLE statement when sent #to_sql' do
          expect(@creator.to_sql).to eq 'CREATE TABLE "people" ("id" SERIAL PRIMARY KEY, "name" VARCHAR(50) NOT NULL, "long_string" VARCHAR(200), ' \
                                        '"very_custom" TEXT)'
        end
      when :sqlite3, :sqlite
        it 'outputs a CREATE TABLE statement when sent #to_sql' do
          expect(@creator.to_sql).to eq 'CREATE TABLE "people" ("id" INTEGER PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(50) NOT NULL, "long_string" ' \
                                        'VARCHAR(200), "very_custom" TEXT)'
        end
      end

      context 'when the default string length is modified' do
        before do
          @original = DataMapper::Property::String.length
          DataMapper::Property::String.length(255)

          @creator = DataMapper::Migration::TableCreator.new(@adapter, :people) do
            column :string, String
          end
        end

        after do
          DataMapper::Property::String.length(@original)
        end

        it 'uses the new length for the character column' do
          expect(@creator.to_sql).to match(/CHAR\(255\)/)
        end
      end
    end

    describe DataMapper::Migration, '#modify_table helper' do
      before do
        @migration = DataMapper::Migration.new(1, :create_people_table, verbose: false) { nil }
      end

      it 'has a #modify_table helper' do
        expect(@migration).to respond_to(:modify_table)
      end

      describe '#change_column' do
        before do
          @modifier = DataMapper::Migration::TableModifier.new(@adapter, :people) do
            change_column :name, 'VARCHAR(200)'
          end
        end

        case DataMapper::Spec.adapter_name.to_sym
        when :mysql
          it 'alters the column' do
            expect(@modifier.to_sql).to eq 'ALTER TABLE `people` MODIFY COLUMN `name` VARCHAR(200)'
          end
        when :postgres
          it 'alters the column' do
            expect(@modifier.to_sql).to eq 'ALTER TABLE "people" ALTER COLUMN "name" VARCHAR(200)'
          end
        end
      end

      describe '#rename_column' do
        case DataMapper::Spec.adapter_name.to_sym
        when :postgres
          before do
            @modifier = DataMapper::Migration::TableModifier.new(@adapter, :people) do
              rename_column :name, :first_name
            end
          end

          it 'renames the column' do
            expect(@modifier.to_sql).to eq 'ALTER TABLE "people" RENAME COLUMN "name" TO "first_name"'
          end
        when :mysql
          before do
            # create the table so the existing column schema can be introspected
            @adapter.execute("CREATE TABLE `people` (name VARCHAR(50) DEFAULT 'John' NOT NULL)")

            @modifier = DataMapper::Migration::TableModifier.new(@adapter, :people) do
              rename_column :name, :first_name
            end
          end

          after do
            @adapter.execute('DROP TABLE `people`')
          end

          it 'changes the column' do
            expect(@modifier.to_sql).to eq "ALTER TABLE `people` CHANGE `name` `first_name` varchar(50) DEFAULT 'John' NOT NULL"
          end
        end
      end
    end

    describe DataMapper::Migration, 'other helpers' do
      before do
        @migration = DataMapper::Migration.new(1, :create_people_table, verbose: false) { nil }
      end

      it 'has a #drop_table helper' do
        expect(@migration).to respond_to(:drop_table)
      end
    end

    describe DataMapper::Migration, 'version tracking' do
      before(:each) do
        @migration = DataMapper::Migration.new(1, :create_people_table, verbose: false) do
          up   { :ran_up }
          down { :ran_down }
        end

        @migration.send(:create_migration_info_table_if_needed)
      end

      after(:each) { DataMapper::Spec.adapter.execute('DROP TABLE migration_info') rescue nil }

      def insert_migration_record
        DataMapper::Spec.adapter.execute("INSERT INTO migration_info (migration_name) VALUES ('create_people_table')")
      end

      it 'knows if the migration_info table exists' do
        expect(@migration.send(:migration_info_table_exists?)).to be(true)
      end

      it 'knows if the migration_info table does not exist' do
        DataMapper::Spec.adapter.execute('DROP TABLE migration_info') rescue nil
        expect(@migration.send(:migration_info_table_exists?)).to be(false)
      end

      it 'is able to find the migration_info record for itself' do
        insert_migration_record
        expect(@migration.send(:migration_record)).not_to be_empty
      end

      it 'knows if a migration needs_up?' do
        expect(@migration.send(:needs_up?)).to be(true)
        insert_migration_record
        expect(@migration.send(:needs_up?)).to be(false)
      end

      it 'knows if a migration needs_down?' do
        expect(@migration.send(:needs_down?)).to be(false)
        insert_migration_record
        expect(@migration.send(:needs_down?)).to be(true)
      end

      it 'properly quotes the migration_info table via the adapter for use in queries' do
        expect(@migration.send(:migration_info_table)).to eq @migration.quote_table_name('migration_info')
      end

      it 'properly quotes the migration_info.migration_name column via the adapter for use in queries' do
        expect(@migration.send(:migration_name_column)).to eq @migration.quote_column_name('migration_name')
      end

      it "properly quotes the migration's name for use in queries"
      # TODO: how to i call the adapter's #escape_sql method?

      it "creates the migration_info table if it doesn't exist" do
        DataMapper::Spec.adapter.execute('DROP TABLE migration_info')
        expect(@migration.send(:migration_info_table_exists?)).to be(false)
        @migration.send(:create_migration_info_table_if_needed)
        expect(@migration.send(:migration_info_table_exists?)).to be(true)
      end

      it 'inserts a record into the migration_info table on up' do
        expect(@migration.send(:migration_record)).to be_empty
        expect(@migration.perform_up).to eq :ran_up
        expect(@migration.send(:migration_record)).not_to be_empty
      end

      it 'removes a record from the migration_info table on down' do
        insert_migration_record
        expect(@migration.send(:migration_record)).not_to be_empty
        expect(@migration.perform_down).to eq :ran_down
        expect(@migration.send(:migration_record)).to be_empty
      end

      it 'does not run the up action if the record exists in the table' do
        insert_migration_record
        expect(@migration.perform_up).not_to eq :ran_up
      end

      it 'does not run the down action if the record does not exist in the table' do
        expect(@migration.perform_down).not_to eq :ran_down
      end
    end
  end
end
