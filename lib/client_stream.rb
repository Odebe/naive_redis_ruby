class ClientStream
  attr_reader :client

  def initialize(client)
    @client = client
  end

  def write(data)
    client.puts(encode(data).join("\r\n") + "\r\n")
  end

  def read
    decode
  end

  private

  def read_line!
    client.gets&.chomp || raise(RESP::ConnectionClosed)
  end

  # TODO: избавиться как-нибудь от рекурсии
  def decode
    msg = read_line!
    type = msg[0]
    body = msg[1..-1]

    case type
    when '-' then raise RESP::ErrorMessageFromClient, body.to_s
    when '+' then body.to_s
    when ':' then body.to_i
    when '$' then read_bulk(body.to_i)
    when '*' then Array.new(body.to_i) { decode }
    else raise RESP::ProtocolError
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
      else
        ['$-1', '']
      end

    arr
  end

  def read_bulk(length)
    return if length == -1

    str = client.read(length)
    client.read(2) # Discard CRLF.
    str
  end
end
