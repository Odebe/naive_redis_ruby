module SortaRedis
  class WorkersPool
    def initialize(size: 5, logger:)
      # thread_id => worker`s storage responses pipe
      @worker_queues = {}
      @queue_mutex = Mutex.new
      @logger = logger
      @queue = Queue.new
      @threads = size.times.map do
        Thread.new do
          thread_tag = "[Worker #{Ractor.current.name}] [Thread #{Thread.current.object_id}]"
          loop do
            @queue.pop.call
          rescue => e
            @logger.error "#{thread_tag} Task finished with error: #{e.message}"
            @logger.error "#{thread_tag} Backtrace:\n#{e.backtrace.join("\n")}"
            next
          end
        end
      end
    end

    def add_client(client)
      worker = SortaRedis::Worker.new(client, Ractor.current[:storage], Ractor.current[:storage_pipe], Ractor.current[:logger])

      enqueue do
        @logger.info "[Worker #{Ractor.current.name}] [Thread #{Thread.current.object_id}] Client #{client.uuid} connected"
        @queue_mutex.synchronize { @worker_queues[Thread.current.object_id] = worker.pipe }
        worker.run! # blocks thread until client disconnect
        @logger.info "[Worker #{Ractor.current.name}] [Thread #{Thread.current.object_id}] Client #{client.uuid} disconnected"
      end
    end

    def find_thread_queue(thread_id)
      @queue_mutex.synchronize { @worker_queues[thread_id] }
    end

    private

    def enqueue(&block)
      @queue.push(block)
    end
  end
end
