module SortaRedis
  module Actor
    class Pipe < Ractor
      def self.new(logger, move: true)
        super(logger, move) do |logger, move|
          loop do
            msg = Ractor.receive
            # logger.debug "[Pipe] received #{msg.inspect}"
            Ractor.yield(msg, move: move)
          end
        end
      end
    end
  end
end
