require 'socket'

threads = 1000.times.map do
  Thread.new do
    socket = TCPSocket.new 'localhost', 9009
    socket.puts "+COMMAND\r"
    sleep 5
    puts socket.gets
    socket.close
  end
end

threads.each { |t| t.join }
