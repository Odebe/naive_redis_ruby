require 'redis'

redis = Redis.new(host: "0.0.0.0", port: 9009)
redis.set("mykey", "hello world")
redis.get("mykey")
redis.close


