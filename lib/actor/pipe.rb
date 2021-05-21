module SortaRedis
  module Actor
    class Pipe < Ractor
      def self.new(logger)
        super(logger) do |logger|
          loop do
            msg = Ractor.receive
            # logger.debug "[Pipe] received #{msg.inspect}"
            Ractor.yield(msg, move: true)
          end
        end
      end
    end
  end
end
