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

      def on_stop(_ractor, state)
        *args, error = state
        unless error.nil?
          @logger.error "[#{name}] Error: #{error.message}"
          @logger.error "[#{name}] Backtrace: #{error.backtrace.join("\n")}" unless error.is_a?(UncaughtThrowError)
        end
      end
    end
  end
end
