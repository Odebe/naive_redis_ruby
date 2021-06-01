require 'securerandom'

module Sorta
  module Redis
    module Protocol
      class Client
        attr_reader :uuid

        def initialize(socket, logger: Logger.new(STDOUT), uuid: SecureRandom.uuid)
          @stream = ClientStream.new(socket)
          @uuid = uuid
          @logger = logger
          @open = true
        end

        def disconnect!
          @stream.disconnect!
        end

        def read
          msg = @stream.read
          @logger.debug "[Worker #{Ractor.current.name}] [Thread #{Thread.current.object_id}] [Client #{@uuid}] reads #{msg.inspect}"
          msg
        end

        def write(msg)
          @logger.debug "[Worker #{Ractor.current.name}] [Thread #{Thread.current.object_id}] [Client #{@uuid}] writes #{msg.inspect}"
          @stream.write msg
        end
      end
    end
  end
end
