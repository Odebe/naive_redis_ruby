module SortaRedis
  module Protocol
    module Errors
      class ConnectionClosed < StandardError
      end

      class ProtocolError < StandardError
      end

      class ErrorMessageFromClient < StandardError
      end
    end
  end
end
