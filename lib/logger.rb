module SortaRedis
  # https://mensfeld.pl/2020/09/building-a-ractor-based-logger-that-will-work-with-non-ractor-compatible-code/
  class Logger < Ractor
    def self.new
      super do
        logger = ::Logger.new($stdout)

        while data = recv
          logger.public_send(data[0], *data[1])
        end
      end
    end

    [:error, :info, :debug].each do |level|
      module_eval(<<~RUBY, __FILE__, __LINE__ + 1)
        def #{level}(*args)
          self << [:#{level}, *args]
        end
      RUBY
    end
  end
end
