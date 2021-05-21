require 'socket'
require 'logger'
require 'securerandom'

Dir['lib/**/*.rb'].each { |path| require_relative path }

logger = SortaRedis::Logger.new
Ractor.current[:logger] = logger

storage = SortaRedis::Actor::Storage.new(logger)
pipe = SortaRedis::Actor::Pipe.new(logger)
receiver = SortaRedis::Actor::Receiver.new(pipe, logger)
workers = 1.times.map { SortaRedis::Actor::Worker.new(pipe, storage, logger) }

SortaRedis::Supervisor::Workers.new(logger, ractors: workers, name: 'Workers Supervisor').start!
SortaRedis::Supervisor::Receiver.new(logger, ractors: [receiver], name: 'Receiver Supervisor').start!

sleep
