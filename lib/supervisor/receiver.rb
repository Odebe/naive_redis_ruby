module SortaRedis
  module Supervisor
    class Receiver
      prepend Prepend
      include Base

      def initialize(logger)
        @logger = logger
      end

      def log(ractor, _state)
        @logger.error "[#{name}] Receiver is dead."
      end

      def on_stop(ractor, state)
        # TODO
      end
    end
  end
end
