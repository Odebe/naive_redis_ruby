class Storage
  def initialize
    @data = {}
    @mutex = Mutex.new
  end

  def get(key)
    @mutex.synchronize { @data[key] }
  end

  def set(key, value)
    @mutex.synchronize { @data[key] = value }
    'OK'
  end
end
