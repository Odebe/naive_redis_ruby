require_relative 'client_stream'
require 'securerandom'

class Client
  attr_reader :uuid

  def initialize(socket, logger: Logger.new(STDOUT), uuid: SecureRandom.uuid)
    @stream = ClientStream.new(socket)
    @uuid = uuid
    @logger = logger
  end

  def run_connection!
    loop do
      msg = @stream.read
      @logger.info "[#{@uuid}] #{msg.inspect}"
      @stream.write 'OK'
    end
  end
end
