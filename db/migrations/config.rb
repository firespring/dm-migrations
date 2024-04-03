DataMapper::Logger.new($stdout, :debug)
DataMapper.logger.debug('Starting Migration')

DataMapper.setup(:default, 'postgres://postgres@localhost/dm_core_test')
