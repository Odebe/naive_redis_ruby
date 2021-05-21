module SortaRedis
  module Actor
    class Storage < Ractor
      def self.new(logger)
        super(logger) do |logger|
          storage = SortaRedis::Protocol::Storage.new
          loop do
            sender, uuid, msg = Ractor.receive
            logger.info "[Storage] receives #{msg.inspect} from #{uuid}"
            response = storage.handle_message(msg)
            logger.info "[Storage] sends #{response.inspect} to #{uuid}"
            sender.send response
          end
        end
      end
    end
  end
end
