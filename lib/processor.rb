class Processor
  def initialize(storage)
    @storage = storage
    @workers = ::ThreadPool.new
  end

  def queue_request(message)
    Queue.new.tap { |result| @workers.queue { result << handle_request(message) } }.pop
  end

  private

  def handle_request(msg)
    case msg
    in ['COMMAND']
      %w[SET GET]
    in ['SET', key, value, *_others]
      @storage.set(key, value)
      'OK'
    in ['GET', key]
      @storage.get(key)
    else
      nil
    end
  end
end
