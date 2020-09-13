class NaiveServer
  def initialize(server, logger: Logger.new(STDOUT))
    @server = server
    @threads = []
    @logger = logger
    @workers = ::ThreadPool.new

    @sm = Mutex.new
    @storage = {}
  end

  def start!
    loop do
      socket = @server.accept
      Thread.new { handle_connection(socket) }
    end
  end

  private

  def handle_request(msg)
    case msg
    in ['COMMAND']
      %w[SET GET]
    in ['SET', key, value, *others]
      @sm.synchronize { @storage[key] = value }
      'OK'
    in ['GET', key]
      @sm.synchronize { @storage[key] }
    end
  end

  def queue_request(queue, msg)
    @workers.queue { queue << handle_request(msg) }
    queue.pop
  end

  def handle_connection(socket)
    uuid = SecureRandom.uuid
    @logger.info "[#{uuid}] Connection established!"

    stream = ClientStream.new(socket)
    client_queue = Queue.new

    loop do
      msg = stream.read
      @logger.info "[#{uuid}] [INCOMING] #{msg}!"
      result = queue_request(client_queue, msg)
      @logger.info "[#{uuid}] [OUTCOMING] #{result}!"
      stream.write result
    end
  rescue RESP::ConnectionClosed
    @logger.info "[#{uuid}] Connection closed!"
    socket.close
  end
end
