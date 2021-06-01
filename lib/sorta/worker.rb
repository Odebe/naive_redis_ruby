module Sorta
  module Redis
    class Worker
      attr_reader :pipe

      def initialize(client, storage, storage_pipe, logger)
        @client = client
        @storage = storage
        @logger = logger
        @storage_pipe = storage_pipe
        @pipe = Queue.new
      end

      def run!
        catch :connection_closed do
          loop do
            msg = @client.read
            # TODO: сделать модуль для обработку команд уровня воркера, а не хранилища
            throw(:connection_closed) if msg.first.upcase == 'DISCONNECT'

            @storage.request(@storage_pipe, msg)
            data = @pipe.pop

            @client.write(data)
          end
        end
      ensure
        @client.disconnect!
      end
    end
  end
end