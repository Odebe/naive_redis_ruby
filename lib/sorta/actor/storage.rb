module Sorta
  module Redis
    module Actor
      class Storage < Ractor
        def self.new(logger)
          super(logger) do |logger|
            storage = Sorta::Redis::Protocol::Storage.new
            loop do
              pipe, thread_id, msg = Ractor.receive
              logger.info "[Storage] receives #{msg.inspect} from [Pipe #{pipe.object_id}] [Thread #{thread_id}]"
              response = storage.handle_message(msg)
              logger.info "[Storage] sends #{response.inspect} to [Pipe #{pipe.object_id}] [Thread #{thread_id}]"
              pipe.send [thread_id, response]
            rescue => e
              # TODO
              next
            end
          end
        end

        def request(pipe, msg)
          self.send [pipe, Thread.current.object_id, msg]
        end
      end
    end
  end
end
