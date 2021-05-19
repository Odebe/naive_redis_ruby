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

    def method_missing(m, *args, &_block)
      self << [m, *args]
    end
  end
end