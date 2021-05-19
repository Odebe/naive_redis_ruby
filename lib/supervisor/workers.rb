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
        @ractors << SortaRedis::Actor::Worker.recreate(*state, name: ractor.name)
      end
    end
  end
end
