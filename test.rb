require 'socket'

threads = 1.times.map do
  Thread.new do
    socket = TCPSocket.new 'localhost', 9009

    socket.puts "+COMMAND\r"
    puts socket.gets

    socket.puts "-PUK\r"
    puts socket.gets

    sleep 1
    socket.close
  end
end

threads.each { |t| t.join }
