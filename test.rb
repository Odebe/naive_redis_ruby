require 'redis'

threads = 10.times.map do
  Thread.new do
    10.times do |i|
      redis = Redis.new(host: "0.0.0.0", port: 9009)
      redis.set(i, i)
      # sleep 0.01
      redis.get(i)
      redis.close
    end
  end
end

threads.map(&:join)

