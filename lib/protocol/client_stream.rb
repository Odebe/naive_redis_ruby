module SortaRedis
  module Protocol
    class ClientStream
      attr_reader :socket

      def initialize(socket)
        @socket = socket
      end

      def disconnect!
        socket.close
      end

      def write(data)
        raw = encode(data).join("\r\n") + "\r\n"
        socket.puts(raw)
      end

      def read
        decode
      end

      private

      def read_line!
        socket.gets&.chomp || throw(:connection_closed)
      end

      # TODO: избавиться как-нибудь от рекурсии
      def decode
        msg = read_line!
        type = msg[0]
        body = msg[1..-1]

        case type
        when '-' then raise Errors::ErrorMessageFromClient, body.to_s
        when '+' then body.to_s
        when ':' then body.to_i
        when '$' then read_bulk(body.to_i)
        when '*' then Array.new(body.to_i) { decode }
        else raise Errors::ProtocolError
        end
      end

      def encode(data)
        arr =
          if data.is_a? Array
            ["*#{data.length}", data.map { |e| encode(e) }]
          elsif data.is_a? String
            ["$#{data.length}", data]
          elsif data.is_a? Integer
            [':', data]
          elsif data == Types::NilValue
            ['$-1']
          else
            raise Errors::ProtocolError
          end
        arr
      end

      def read_bulk(length)
        return if length == -1

        str = socket.read(length)
        socket.read(2) # Discard CRLF.
        str
      end
    end
  end
end

