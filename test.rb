require 'redis'

100.times do
  2.times.map do
    Thread.new do
      25.times do |i|
        redis = Redis.new(host: "0.0.0.0", port: 9009)
        redis.set(i, i)
        redis.get(i)
        sleep 0.01
        redis.close
      end
    end
  end.each(&:join)
end


#
# pipe1 = Ractor.new do
#   loop do
#     msg = Ractor.receive
#     puts "pipe1 received: #{msg}"
#     Ractor.yield(msg, move: true)
#   end
# end
#
# pipe2 = Ractor.new do
#   loop do
#     msg = Ractor.receive
#     puts "pipe2 received: #{msg}"
#     Ractor.yield(msg, move: true)
#   end
# end
#
# Ractor.new(pipe1, pipe2) do |pipe1, pipe2|
#   Thread.new do
#     loop do
#       msg = pipe1.take
#       puts "thread1 [pipe1]: #{msg}"
#     end
#   end
#
#   Thread.new do
#     loop do
#       msg = pipe2.take
#       puts "thread2 [pipe2]: #{msg}"
#     end
#   end
#
#   sleep
# end
#
# 3.times do |i|
#   Thread.new do
#     pipe1.send("#{i} was sent to pipe1")
#   # end
#   # Thread.new do
#     pipe2.send("#{i} was sent to pipe2")
#   end
# end
#
# sleep


