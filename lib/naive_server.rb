class NaiveServer
  def initialize(server, logger: Logger.new(STDOUT))
    @server = server
    @logger = logger
    @storage = Storage.new
    @processor = Processor.new(@storage)
  end

  def start!
    loop do
      socket = @server.accept
      Thread.new { handle_connection(socket) }
    end
  end

  private

  def handle_connection(socket)
    uuid = SecureRandom.uuid
    @logger.info "[#{uuid}] Connection established!"

    stream = ClientStream.new(socket)
    loop do
      msg = stream.read
      @logger.info "[#{uuid}] [INCOMING] #{msg.inspect}!"
      result = @processor.queue_request(msg)
      @logger.info "[#{uuid}] [OUTCOMING] #{result.inspect}!"
      stream.write result
    end
  rescue RESP::ConnectionClosed
    @logger.info "[#{uuid}] Connection closed!"
    socket.close
  end
end
