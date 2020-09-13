module RESP
  class ConnectionClosed < StandardError
  end

  class ProtocolError < StandardError
  end

  class ErrorMessageFromClient < StandardError
  end
end
