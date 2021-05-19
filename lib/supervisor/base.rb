module SortaRedis
  module Supervisor
    module Prepend
      attr_reader :name

      def initialize(*args, name:, ractors:)
        super(*args)

        @ractors = ractors
        @name = name
      end
    end

    module Base
      def start!
        Thread.new do
          ractor, state = Ractor.select(*@ractors)
          log(ractor, state)
          on_stop(ractor, state)
        end
      end

      def log(ractor, obj)
        raise 'abstract method'
      end

      def on_stop(ractor, obj)
        raise 'abstract method'
      end
    end
  end
end
