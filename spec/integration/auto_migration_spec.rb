require_relative '../spec_helper'

require 'dm-migrations/auto_migration'

module DataMapper
  class Property
    class NumericString < DataMapper::Property::String
      default 0

      def dump(value)
        return if value.nil?

        value.to_s
      end
    end
  end
end

module ::Blog
  class Article
    include DataMapper::Resource
  end
end

describe DataMapper::Migrations do
  def capture_log(mod)
    original = mod.logger
    mod.logger = DataObjects::Logger.new(@log = StringIO.new, :debug)
    yield
  ensure
    @log.rewind
    @output = @log.readlines.map do |line|
      line.chomp.gsub(/\A.+?~ \(\d+\.?\d*\)\s+/, '')
    end

    mod.logger = original
  end

  supported_by :mysql do
    before :all do
      @model = Blog::Article
    end

    describe '#auto_migrate' do
      describe 'Integer property' do
        [
          [0,                    1, 'TINYINT(1) UNSIGNED'],
          [0,                    9, 'TINYINT(1) UNSIGNED'],
          [0,                   10, 'TINYINT(2) UNSIGNED'],
          [0,                   99, 'TINYINT(2) UNSIGNED'],
          [0,                  100, 'TINYINT(3) UNSIGNED'],
          [0,                  255, 'TINYINT(3) UNSIGNED'],
          [0,                  256, 'SMALLINT(3) UNSIGNED'],
          [0,                  999, 'SMALLINT(3) UNSIGNED'],
          [0,                 1000, 'SMALLINT(4) UNSIGNED'],
          [0,                 9999, 'SMALLINT(4) UNSIGNED'],
          [0,                10_000, 'SMALLINT(5) UNSIGNED'],
          [0,                65_535, 'SMALLINT(5) UNSIGNED'],
          [0,                65_536, 'MEDIUMINT(5) UNSIGNED'],
          [0,                99_999, 'MEDIUMINT(5) UNSIGNED'],
          [0,               100_000, 'MEDIUMINT(6) UNSIGNED'],
          [0,               999_999, 'MEDIUMINT(6) UNSIGNED'],
          [0,              1_000_000, 'MEDIUMINT(7) UNSIGNED'],
          [0,              9_999_999, 'MEDIUMINT(7) UNSIGNED'],
          [0,             10_000_000, 'MEDIUMINT(8) UNSIGNED'],
          [0,             16_777_215, 'MEDIUMINT(8) UNSIGNED'],
          [0,             16_777_216, 'INT(8) UNSIGNED'],
          [0,             99_999_999, 'INT(8) UNSIGNED'],
          [0,            100_000_000, 'INT(9) UNSIGNED'],
          [0,            999_999_999, 'INT(9) UNSIGNED'],
          [0,           1_000_000_000, 'INT(10) UNSIGNED'],
          [0,           4_294_967_295, 'INT(10) UNSIGNED'],
          [0,           4_294_967_296, 'BIGINT(10) UNSIGNED'],
          [0,           9_999_999_999, 'BIGINT(10) UNSIGNED'],
          [0,          10_000_000_000, 'BIGINT(11) UNSIGNED'],
          [0,          99_999_999_999, 'BIGINT(11) UNSIGNED'],
          [0,         100_000_000_000, 'BIGINT(12) UNSIGNED'],
          [0,         999_999_999_999, 'BIGINT(12) UNSIGNED'],
          [0,        1_000_000_000_000, 'BIGINT(13) UNSIGNED'],
          [0,        9_999_999_999_999, 'BIGINT(13) UNSIGNED'],
          [0,       10_000_000_000_000, 'BIGINT(14) UNSIGNED'],
          [0,       99_999_999_999_999, 'BIGINT(14) UNSIGNED'],
          [0,      100_000_000_000_000, 'BIGINT(15) UNSIGNED'],
          [0,      999_999_999_999_999, 'BIGINT(15) UNSIGNED'],
          [0,     1_000_000_000_000_000, 'BIGINT(16) UNSIGNED'],
          [0,     9_999_999_999_999_999, 'BIGINT(16) UNSIGNED'],
          [0,    10_000_000_000_000_000, 'BIGINT(17) UNSIGNED'],
          [0,    99_999_999_999_999_999, 'BIGINT(17) UNSIGNED'],
          [0,   100_000_000_000_000_000, 'BIGINT(18) UNSIGNED'],
          [0,   999_999_999_999_999_999, 'BIGINT(18) UNSIGNED'],
          [0,  1_000_000_000_000_000_000, 'BIGINT(19) UNSIGNED'],
          [0,  9_999_999_999_999_999_999, 'BIGINT(19) UNSIGNED'],
          [0, 10_000_000_000_000_000_000, 'BIGINT(20) UNSIGNED'],
          [0, 18_446_744_073_709_551_615, 'BIGINT(20) UNSIGNED'],

          [-1,                    0, 'TINYINT(2)'],
          [-1,                    9, 'TINYINT(2)'],
          [-1,                   10, 'TINYINT(2)'],
          [-1,                   99, 'TINYINT(2)'],
          [-1,                  100, 'TINYINT(3)'],
          [-1,                  127, 'TINYINT(3)'],
          [-1,                  128, 'SMALLINT(3)'],
          [-1,                  999, 'SMALLINT(3)'],
          [-1,                 1000, 'SMALLINT(4)'],
          [-1,                 9999, 'SMALLINT(4)'],
          [-1,                10_000, 'SMALLINT(5)'],
          [-1,                32_767, 'SMALLINT(5)'],
          [-1,                32_768, 'MEDIUMINT(5)'],
          [-1,                99_999, 'MEDIUMINT(5)'],
          [-1,               100_000, 'MEDIUMINT(6)'],
          [-1,               999_999, 'MEDIUMINT(6)'],
          [-1,              1_000_000, 'MEDIUMINT(7)'],
          [-1,              8_388_607, 'MEDIUMINT(7)'],
          [-1,              8_388_608, 'INT(7)'],
          [-1,              9_999_999, 'INT(7)'],
          [-1,             10_000_000, 'INT(8)'],
          [-1,             99_999_999, 'INT(8)'],
          [-1,            100_000_000, 'INT(9)'],
          [-1,            999_999_999, 'INT(9)'],
          [-1,           1_000_000_000, 'INT(10)'],
          [-1,           2_147_483_647, 'INT(10)'],
          [-1,           2_147_483_648, 'BIGINT(10)'],
          [-1,           9_999_999_999, 'BIGINT(10)'],
          [-1,          10_000_000_000, 'BIGINT(11)'],
          [-1,          99_999_999_999, 'BIGINT(11)'],
          [-1,         100_000_000_000, 'BIGINT(12)'],
          [-1,         999_999_999_999, 'BIGINT(12)'],
          [-1,        1_000_000_000_000, 'BIGINT(13)'],
          [-1,        9_999_999_999_999, 'BIGINT(13)'],
          [-1,       10_000_000_000_000, 'BIGINT(14)'],
          [-1,       99_999_999_999_999, 'BIGINT(14)'],
          [-1,      100_000_000_000_000, 'BIGINT(15)'],
          [-1,      999_999_999_999_999, 'BIGINT(15)'],
          [-1,     1_000_000_000_000_000, 'BIGINT(16)'],
          [-1,     9_999_999_999_999_999, 'BIGINT(16)'],
          [-1,    10_000_000_000_000_000, 'BIGINT(17)'],
          [-1,    99_999_999_999_999_999, 'BIGINT(17)'],
          [-1,   100_000_000_000_000_000, 'BIGINT(18)'],
          [-1,   999_999_999_999_999_999, 'BIGINT(18)'],
          [-1,  1_000_000_000_000_000_000, 'BIGINT(19)'],
          [-1,  9_223_372_036_854_775_807, 'BIGINT(19)'],

          [-1,                    0, 'TINYINT(2)'],
          [-9,                    0, 'TINYINT(2)'],
          [-10,                    0, 'TINYINT(3)'],
          [-99,                    0, 'TINYINT(3)'],
          [-100,                    0, 'TINYINT(4)'],
          [-128,                    0, 'TINYINT(4)'],
          [-129,                    0, 'SMALLINT(4)'],
          [-999,                    0, 'SMALLINT(4)'],
          [-1000,                    0, 'SMALLINT(5)'],
          [-9999,                    0, 'SMALLINT(5)'],
          [-10_000,                    0, 'SMALLINT(6)'],
          [-32_768,                    0, 'SMALLINT(6)'],
          [-32_769,                    0, 'MEDIUMINT(6)'],
          [-99_999,                    0, 'MEDIUMINT(6)'],
          [-100_000,                    0, 'MEDIUMINT(7)'],
          [-999_999,                    0, 'MEDIUMINT(7)'],
          [-1_000_000,                    0, 'MEDIUMINT(8)'],
          [-8_388_608,                    0, 'MEDIUMINT(8)'],
          [-8_388_609,                    0, 'INT(8)'],
          [-9_999_999,                    0, 'INT(8)'],
          [-10_000_000,                    0, 'INT(9)'],
          [-99_999_999,                    0, 'INT(9)'],
          [-100_000_000,                    0, 'INT(10)'],
          [-999_999_999,                    0, 'INT(10)'],
          [-1_000_000_000,                    0, 'INT(11)'],
          [-2_147_483_648,                    0, 'INT(11)'],
          [-2_147_483_649,                    0, 'BIGINT(11)'],
          [-9_999_999_999,                    0, 'BIGINT(11)'],
          [-10_000_000_000,                    0, 'BIGINT(12)'],
          [-99_999_999_999,                    0, 'BIGINT(12)'],
          [-100_000_000_000,                    0, 'BIGINT(13)'],
          [-999_999_999_999,                    0, 'BIGINT(13)'],
          [-1_000_000_000_000,                    0, 'BIGINT(14)'],
          [-9_999_999_999_999,                    0, 'BIGINT(14)'],
          [-10_000_000_000_000,                    0, 'BIGINT(15)'],
          [-99_999_999_999_999,                    0, 'BIGINT(15)'],
          [-100_000_000_000_000,                    0, 'BIGINT(16)'],
          [-999_999_999_999_999,                    0, 'BIGINT(16)'],
          [-1_000_000_000_000_000,                    0, 'BIGINT(17)'],
          [-9_999_999_999_999_999,                    0, 'BIGINT(17)'],
          [-10_000_000_000_000_000,                    0, 'BIGINT(18)'],
          [-99_999_999_999_999_999,                    0, 'BIGINT(18)'],
          [-100_000_000_000_000_000,                    0, 'BIGINT(19)'],
          [-999_999_999_999_999_999,                    0, 'BIGINT(19)'],
          [-1_000_000_000_000_000_000,                    0, 'BIGINT(20)'],
          [-9_223_372_036_854_775_808,                    0, 'BIGINT(20)'],

          [nil, 2_147_483_647, 'INT(10) UNSIGNED'],
          [0, nil, 'INT(10) UNSIGNED'],
          [nil, nil, 'INTEGER']
        ].each do |min, max, statement|
          options = {key: true}
          options[:min] = min if min
          options[:max] = max if max

          describe "with a min of #{min} and a max of #{max}" do
            before :all do
              @property = @model.property(:id, Integer, options)

              @response = capture_log(DataObjects::Mysql) { @model.auto_migrate! }
            end

            it 'should return true' do
              @response.should be(true)
            end

            it "should create a #{statement} column" do
              @output.last.should =~ /\ACREATE TABLE `blog_articles` \(`id` #{Regexp.escape(statement)} NOT NULL, PRIMARY KEY\(`id`\)\) ENGINE = InnoDB CHARACTER SET [a-z\d]+ COLLATE (?:[a-z\d](?:_?[a-z\d]+)*)\z/
            end

            %i(min max).each do |key|
              next unless (value = options[key])

              it "should allow the #{key} value #{value} to be stored" do
                pending_if "#{value} causes problem with JRuby 1.5.2 parser",
                           RUBY_PLATFORM[/java/] && JRUBY_VERSION < '1.5.6' && value == -9_223_372_036_854_775_808 do
                  lambda {
                    resource = @model.create(@property => value)
                    @model.first(@property => value).should == resource
                  }.should_not raise_error
                end
              end
            end
          end
        end

        describe 'with a property that dumps as integer but has no min or max' do
          before :all do
            klass = Class.new(DataMapper::Property::Object) do
              load_as Integer
              dump_as Integer
            end

            @model.property(:id,     DataMapper::Property::Serial)
            @model.property(:number, klass)

            @response = capture_log(DataObjects::Mysql) { @model.auto_migrate! }
          end

          it 'should create an INTEGER column' do
            @output.last.should =~ /\ACREATE TABLE `blog_articles` \(`id` INT\(10\) UNSIGNED NOT NULL AUTO_INCREMENT, `number` INTEGER, PRIMARY KEY\(`id`\)\) ENGINE = InnoDB CHARACTER SET [a-z\d]+ COLLATE [a-z\d](?:_?[a-z\d]+)*\z/
          end
        end
      end

      describe 'Text property' do
        before :all do
          @model.property(:id, DataMapper::Property::Serial)
        end

        [
          [0,          'TINYTEXT'],
          [1,          'TINYTEXT'],
          [255,        'TINYTEXT'],
          [256,        'TEXT'],
          [65_535,      'TEXT'],
          [65_536,      'MEDIUMTEXT'],
          [16_777_215,   'MEDIUMTEXT'],
          [16_777_216,   'LONGTEXT'],
          [4_294_967_295, 'LONGTEXT'],

          [nil, 'TEXT']
        ].each do |length, statement|
          options = {}
          options[:length] = length if length

          describe "with a length of #{length}" do
            before :all do
              @property = @model.property(:body, DataMapper::Property::Text, options)

              @response = capture_log(DataObjects::Mysql) { @model.auto_migrate! }
            end

            it 'should return true' do
              @response.should be(true)
            end

            it "should create a #{statement} column" do
              @output.last.should =~ /\ACREATE TABLE `blog_articles` \(`id` INT\(10\) UNSIGNED NOT NULL AUTO_INCREMENT, `body` #{Regexp.escape(statement)}, PRIMARY KEY\(`id`\)\) ENGINE = InnoDB CHARACTER SET [a-z\d]+ COLLATE (?:[a-z\d](?:_?[a-z\d]+)*)\z/
            end
          end
        end
      end

      describe 'String property' do
        before :all do
          @model.property(:id, DataMapper::Property::Serial)
        end

        [
          [1,          'VARCHAR(1)'],
          [50,         'VARCHAR(50)'],
          [255,        'VARCHAR(255)'],
          [nil,        'VARCHAR(50)']
        ].each do |length, statement|
          options = {}
          options[:length] = length if length

          describe "with a length of #{length}" do
            before :all do
              @property = @model.property(:title, String, options)

              @response = capture_log(DataObjects::Mysql) { @model.auto_migrate! }
            end

            it 'should return true' do
              @response.should be(true)
            end

            it "should create a #{statement} column" do
              @output.last.should =~ /\ACREATE TABLE `blog_articles` \(`id` INT\(10\) UNSIGNED NOT NULL AUTO_INCREMENT, `title` #{Regexp.escape(statement)}, PRIMARY KEY\(`id`\)\) ENGINE = InnoDB CHARACTER SET [a-z\d]+ COLLATE (?:[a-z\d](?:_?[a-z\d]+)*)\z/
            end
          end
        end
      end

      describe 'NumericString property' do
        before :all do
          @model.property(:id,     DataMapper::Property::Serial)
          @model.property(:number, DataMapper::Property::NumericString)

          @response = capture_log(DataObjects::Mysql) { @model.auto_migrate! }
        end

        it "should create a VARCHAR(50) column with a default of '0'" do
          @output.last.should =~ /\ACREATE TABLE `blog_articles` \(`id` INT\(10\) UNSIGNED NOT NULL AUTO_INCREMENT, `number` VARCHAR\(50\) DEFAULT '0', PRIMARY KEY\(`id`\)\) ENGINE = InnoDB CHARACTER SET [a-z\d]+ COLLATE [a-z\d](?:_?[a-z\d]+)*\z/
        end
      end

      describe 'IntegerDumpedAsString property' do
        before :all do
          klass = Class.new(DataMapper::Property::Object) do
            load_as Integer
            dump_as String

            attr_reader :length
          end

          @model.property(:id,     DataMapper::Property::Serial)
          @model.property(:number, klass)

          @response = capture_log(DataObjects::Mysql) { @model.auto_migrate! }
        end

        it 'should create a large VARCHAR column' do
          @output.last.should =~ /\ACREATE TABLE `blog_articles` \(`id` INT\(10\) UNSIGNED NOT NULL AUTO_INCREMENT, `number` VARCHAR\(16383\), PRIMARY KEY\(`id`\)\) ENGINE = InnoDB CHARACTER SET [a-z\d]+ COLLATE [a-z\d](?:_?[a-z\d]+)*\z/
        end
      end
    end
  end

  supported_by :postgres do
    before :all do
      @model = Blog::Article
    end

    describe '#auto_migrate' do
      describe 'Integer property' do
        [
          [0, 1, 'SMALLINT'],
          [0,               32_767, 'SMALLINT'],
          [0,               32_768, 'INTEGER'],
          [0,          2_147_483_647, 'INTEGER'],
          [0,          2_147_483_648, 'BIGINT'],
          [0, 9_223_372_036_854_775_807, 'BIGINT'],

          [-1, 1, 'SMALLINT'],
          [-1,               32_767, 'SMALLINT'],
          [-1,               32_768, 'INTEGER'],
          [-1,          2_147_483_647, 'INTEGER'],
          [-1,          2_147_483_648, 'BIGINT'],
          [-1, 9_223_372_036_854_775_807, 'BIGINT'],

          [-1, 0, 'SMALLINT'],
          [-32_768,                   0, 'SMALLINT'],
          [-32_769,                   0, 'INTEGER'],
          [-2_147_483_648,                   0, 'INTEGER'],
          [-2_147_483_649,                   0, 'BIGINT'],
          [-9_223_372_036_854_775_808, 0, 'BIGINT'],

          [nil, 2_147_483_647, 'INTEGER'],
          [0, nil, 'INTEGER'],
          [nil, nil, 'INTEGER']
        ].each do |min, max, statement|
          options = {key: true}
          options[:min] = min if min
          options[:max] = max if max

          describe "with a min of #{min} and a max of #{max}" do
            before :all do
              @property = @model.property(:id, Integer, options)

              @response = capture_log(DataObjects::Postgres) { @model.auto_migrate! }
            end

            it 'should return true' do
              @response.should be(true)
            end

            it "should create a #{statement} column" do
              @output[-2].should == "CREATE TABLE \"blog_articles\" (\"id\" #{statement} NOT NULL, PRIMARY KEY(\"id\"))"
            end

            %i(min max).each do |key|
              next unless (value = options[key])

              it "should allow the #{key} value #{value} to be stored" do
                pending_if "#{value} causes problem with the JRuby < 1.6 parser",
                           RUBY_PLATFORM =~ /java/ && JRUBY_VERSION < '1.6' && value == -9_223_372_036_854_775_808 do
                  lambda {
                    resource = @model.create(@property => value)
                    @model.first(@property => value).should eql(resource)
                  }.should_not raise_error
                end
              end
            end
          end
        end
      end

      describe 'Serial property' do
        [
          [1, 'SERIAL'],
          [2_147_483_647, 'SERIAL'],
          [2_147_483_648, 'BIGSERIAL'],
          [9_223_372_036_854_775_807, 'BIGSERIAL'],

          [nil, 'SERIAL']
        ].each do |max, statement|
          options = {}
          options[:max] = max if max

          describe "with a max of #{max}" do
            before :all do
              @property = @model.property(:id, DataMapper::Property::Serial, options)

              @response = capture_log(DataObjects::Postgres) { @model.auto_migrate! }
            end

            it 'should return true' do
              @response.should be(true)
            end

            it "should create a #{statement} column" do
              @output[-2].should == "CREATE TABLE \"blog_articles\" (\"id\" #{statement} NOT NULL, PRIMARY KEY(\"id\"))"
            end

            %i(min max).each do |key|
              next unless (value = options[key])

              it "should allow the #{key} value #{value} to be stored" do
                lambda {
                  resource = @model.create(@property => value)
                  @model.first(@property => value).should eql(resource)
                }.should_not raise_error
              end
            end
          end
        end
      end

      describe 'String property' do
        before :all do
          @model.property(:id, DataMapper::Property::Serial)
        end

        [
          [1,          'VARCHAR(1)'],
          [50,         'VARCHAR(50)'],
          [255,        'VARCHAR(255)'],
          [nil,        'VARCHAR(50)']
        ].each do |length, statement|
          options = {}
          options[:length] = length if length

          describe "with a length of #{length}" do
            before :all do
              @property = @model.property(:title, String, options)

              @response = capture_log(DataObjects::Postgres) { @model.auto_migrate! }
            end

            it 'should return true' do
              @response.should be(true)
            end

            it "should create a #{statement} column" do
              @output[-2].should == "CREATE TABLE \"blog_articles\" (\"id\" SERIAL NOT NULL, \"title\" #{statement}, PRIMARY KEY(\"id\"))"
            end
          end
        end
      end

      describe 'NumericString property' do
        before :all do
          @model.property(:id,     DataMapper::Property::Serial)
          @model.property(:number, DataMapper::Property::NumericString)

          @response = capture_log(DataObjects::Postgres) { @model.auto_migrate! }
        end

        it "should create a VARCHAR(50) column with a default of '0'" do
          @output[-2].should == "CREATE TABLE \"blog_articles\" (\"id\" SERIAL NOT NULL, \"number\" VARCHAR(50) DEFAULT '0', PRIMARY KEY(\"id\"))"
        end
      end
    end
  end

  supported_by :sqlserver do
    before :all do
      @model = Blog::Article
    end

    describe '#auto_migrate' do
      describe 'Integer property' do
        [
          [0, 1, 'TINYINT'],
          [0,                 255, 'TINYINT'],
          [0,                 256, 'SMALLINT'],
          [0,               32_767, 'SMALLINT'],
          [0,               32_768, 'INT'],
          [0,          2_147_483_647, 'INT'],
          [0,          2_147_483_648, 'BIGINT'],
          [0, 9_223_372_036_854_775_807, 'BIGINT'],

          [-1, 1, 'SMALLINT'],
          [-1,                 255, 'SMALLINT'],
          [-1,                 256, 'SMALLINT'],
          [-1,               32_767, 'SMALLINT'],
          [-1,               32_768, 'INT'],
          [-1,          2_147_483_647, 'INT'],
          [-1,          2_147_483_648, 'BIGINT'],
          [-1, 9_223_372_036_854_775_807, 'BIGINT'],

          [-1, 0, 'SMALLINT'],
          [-32_768,                   0, 'SMALLINT'],
          [-32_769,                   0, 'INT'],
          [-2_147_483_648,                   0, 'INT'],
          [-2_147_483_649,                   0, 'BIGINT'],
          [-9_223_372_036_854_775_808, 0, 'BIGINT'],

          [nil, 2_147_483_647, 'INT'],
          [0, nil, 'INT'],
          [nil, nil, 'INTEGER']
        ].each do |min, max, statement|
          options = {key: true}
          options[:min] = min if min
          options[:max] = max if max

          describe "with a min of #{min} and a max of #{max}" do
            before :all do
              @property = @model.property(:id, Integer, options)

              @response = capture_log(DataObjects::Sqlserver) { @model.auto_migrate! }
            end

            it 'should return true' do
              @response.should be(true)
            end

            it "should create a #{statement} column" do
              @output.last.should == "CREATE TABLE \"blog_articles\" (\"id\" #{statement} NOT NULL, PRIMARY KEY(\"id\"))"
            end

            %i(min max).each do |key|
              next unless (value = options[key])

              it "should allow the #{key} value #{value} to be stored" do
                pending_if "#{value} causes problem with JRuby 1.5.2 parser", RUBY_PLATFORM =~ /java/ && value == -9_223_372_036_854_775_808 do
                  lambda {
                    resource = @model.create(@property => value)
                    @model.first(@property => value).should eql(resource)
                  }.should_not raise_error
                end
              end
            end
          end
        end
      end

      describe 'String property' do
        it 'needs specs'
      end
    end
  end
end
