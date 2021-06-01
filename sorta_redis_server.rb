require 'logger'
require 'securerandom'

Dir['lib/sorta/**/*.rb'].each { |path| require_relative path }

logger = Sorta::Redis::Logger.new
Ractor.current[:logger] = logger

storage = Sorta::Redis::Actor::Storage.new(logger)
pipe = Sorta::Redis::Actor::Pipe.new(logger, move: true)

receiver = Sorta::Redis::Actor::Receiver.new(pipe, logger)
workers = 2.times.map { Sorta::Redis::Actor::Worker.new(pipe, storage, logger) }

Sorta::Redis::Supervisor::Workers.new(logger, ractors: workers, name: 'Workers Supervisor').start!
Sorta::Redis::Supervisor::Receiver.new(logger, ractors: [receiver], name: 'Receiver Supervisor').start!

sleep
