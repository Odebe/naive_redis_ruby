require 'socket'
require 'logger'

Dir['lib/**/*'].each { |path| require_relative path }

tcp_server = TCPServer.new('0.0.0.0', 9009)
redis = NaiveServer.new(tcp_server)
redis.start!
