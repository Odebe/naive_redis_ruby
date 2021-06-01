module Sorta
  module Redis
    module Actor
      class Worker < Ractor
        def self.new(pipe, storage, logger)
          super(pipe, storage, logger, name: SecureRandom.uuid) do |receiver_pipe, storage, logger|
            Ractor.current[:receiver_pipe] = receiver_pipe
            Ractor.current[:logger] = logger

            Ractor.current[:storage] = storage
            thread_pool = Sorta::Redis::WorkersPool.new(size: 5, logger: logger)
            storage_pipe = Sorta::Redis::Actor::Pipe.new(logger, move: false)
            Ractor.current[:storage_pipe] = storage_pipe

            Ractor.current[:logger].info "[Worker #{Ractor.current.name}] Started"
            loop do
              ractor, obj = Ractor.select(Ractor.current[:receiver_pipe], Ractor.current[:storage_pipe])
              if ractor == receiver_pipe
                thread_pool.add_client(obj)
              else
                thread_id, response = obj
                queue = thread_pool.find_thread_queue(thread_id)

                if queue.nil?
                  Ractor.current[:logger].error "[Worker #{Ractor.current.name}] Cannot find worker queue for thread #{thread_id}"
                  next
                end

                queue.push(response)
              end
            end
          rescue => e
            # returns state for recreating
            Ractor.yield([Ractor.current[:pipe], Ractor.current[:storage], Ractor.current[:logger], Ractor.current[:storage_pipe], e], move: true)
          end
        end

        def self.recreate(*args, name:)
          Ractor.current[:logger].info "[Workers Supervisor] Recreating Worker #{name}"
          new(*args)
        end
      end
    end
  end
end
