require 'socket'
require 'logger'
require 'securerandom'

Dir['lib/**/*'].each { |path| require_relative path }

logger = SortaRedis::Logger.new

storage_ractor = Ractor.new(logger) do |logger|
  storage = Storage.new
  loop do
    sender, uuid, msg = Ractor.receive
    logger.info "[Storage] receives #{msg.inspect} from #{uuid}"
    response = storage.handle_message(msg)
    logger.info "[Storage] sends #{response.inspect} to #{uuid}"
    sender.send response
  end
end

pipe_to_workers = Ractor.new(logger) do |logger|
  loop do
    incoming = Ractor.receive
    Ractor.yield(incoming, move: true)
  end
end

def create_worker(pipe_to_workers, storage_ractor, logger, number)
  Ractor.new(pipe_to_workers, storage_ractor, logger, name: number.to_s) do |pipe, storage, logger|
    raise 'oh no' if Ractor.current.name == '0'
    logger.info "[Worker #{Ractor.current.name}] Started"

    loop do
      client = pipe.take
      logger.info "[Worker #{Ractor.current.name}] client #{client.uuid} connected"
      catch :connection_closed do
        loop do
          msg = client.read
          # TODO: сделать модуль для обработку команд уровня воркера, а не хранилища
          client.disconnect! if msg.first.upcase == 'DISCONNECT'

          storage.send [Ractor.current, client.uuid, msg].freeze
          response = Ractor.receive
          client.write(response)
        end
      end
      logger.info "[Worker #{Ractor.current.name}] user #{client.uuid} disconnected"
    end
  end
end

workers = 10.times.map { |number| create_worker(pipe_to_workers, storage_ractor, logger, number) }

Thread.new do
  loop do
    _, _ = Ractor.select(*workers)
  rescue Ractor::RemoteError => e
    logger.error "[Workers Supervisor] Worker #{e.ractor.name} is dead. Error: '#{e.cause.message}'"
    workers.delete(e.ractor)
    workers << create_worker(pipe_to_workers, storage_ractor, logger, e.ractor.name + '_')
    next
  end
end


receiver = Ractor.new(pipe_to_workers, logger) do |pipe, logger|
  tcp_server = TCPServer.new('0.0.0.0', 9009)
  loop do
    socket = tcp_server.accept
    pipe.send(Client.new(socket, logger: logger), move: true)
  end
end

Thread.new do
  loop do
    receiver.take
  rescue Ractor::RemoteError => e
    logger.error "[Receiver SUPERVISOR] Receiver is dead. Error: '#{e.cause.message}'"
  end
end


sleep

