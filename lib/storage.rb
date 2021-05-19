class Storage
  def initialize
    @data = {}
    @mutex = Mutex.new
  end

  def handle_message(msg)
    case normalize_(msg)
    in ['COMMAND']
      %w[SET GET]
    in ['SET', key, value, *_others]
      set(key, value)
      'OK'
    in ['GET', key]
      get(key)
    else
      Types::NilValue
    end
  end

  def get(key)
    @mutex.synchronize { @data[key] } || Types::NilValue
  end

  def set(key, value)
    @mutex.synchronize { @data[key] = value }
    'OK'
  end

  private

  def normalize_(msg)
    [msg[0].upcase] + msg[1..-1]
  end
end
