require 'socket'
require 'logger'
require 'securerandom'

Dir['lib/**/*.rb'].each { |path| require_relative path }

logger = SortaRedis::Logger.new
Ractor.current[:logger] = logger

# TODO
storage_ractor = Ractor.new(logger) do |logger|
  storage = SortaRedis::Protocol::Storage.new
  loop do
    sender, uuid, msg = Ractor.receive
    logger.info "[Storage] receives #{msg.inspect} from #{uuid}"
    response = storage.handle_message(msg)
    logger.info "[Storage] sends #{response.inspect} to #{uuid}"
    sender.send response
  end
end

# Pipe for messages from receiver to workers
pipe = Ractor.new(logger) do |logger|
  loop do
    msg = Ractor.receive
    # logger.debug "[Pipe] received #{msg.inspect}"
    Ractor.yield(msg, move: true)
  end
end

# Creating Workers
workers = 4.times.map { SortaRedis::Actor::Worker.new(pipe, storage_ractor, logger) }
receiver = SortaRedis::Actor::Receiver.new(pipe, logger)

# Creating supervisors
SortaRedis::Supervisor::Workers.new(logger, ractors: workers, name: 'Workers Supervisor').start!
SortaRedis::Supervisor::Workers.new(logger, ractors: [receiver], name: 'Receiver Supervisor').start!

sleep
