module SortaRedis
  module Supervisor
    class Workers
      prepend Prepend
      include Base

      def initialize(logger)
        @logger = logger
      end

      def log(ractor, _state)
        @logger.error "[#{name}] Ractor #{ractor.name} is dead."
      end

      def on_stop(ractor, state)
        @ractors.delete(ractor)

        *args, error = state[3]
        @logger.error "[#{name}] Error: #{error.message}"
        @logger.error "[#{name}] Backtrace: #{error.backtrace.join("\n")}" unless error.is_a?(UncaughtThrowError)

        @ractors << SortaRedis::Actor::Worker.recreate(*args, name: ractor.name)
      end
    end
  end
end
