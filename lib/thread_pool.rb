class ThreadPool
  def initialize(size: 10)
    @queue = Queue.new
    @pool = []
    @size = size
    @mutex = Mutex.new

    size.times { start_thread! }
  end

  def queue(*args, &block)
    @queue << [block, args]
  end

  private

  def start_thread!
    Thread.new do
      add_thread Thread.current
        loop do
          task, args = @queue.pop
          task.call(*args)
        end
      delete_thread Thread.current
      start_thread!
    end
  end

  def add_thread(thread)
    @mutex.synchronize do
      @pool << thread
    end
  end

  def delete_thread(thread)
    @mutex.synchronize do
      @pool.delete(thread)
    end
  end
end
