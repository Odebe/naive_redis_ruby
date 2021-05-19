module SortaRedis
  module Actor
    class Worker < Ractor
      def self.new(pipe, storage, logger)
        super(pipe, storage, logger, name: SecureRandom.uuid) do |pipe, storage, logger|
          logger.info "[Worker #{Ractor.current.name}] Started"

          Ractor.current[:pipe] = pipe
          Ractor.current[:storage] = storage
          Ractor.current[:logger] = logger

          loop { SortaRedis::Actor::Worker.user_tick }
        rescue
          Ractor.yield([Ractor.current[:pipe], Ractor.current[:storage], Ractor.current[:logger]])
        end
      end

      def self.user_tick
        client = Ractor.current[:pipe].take
        Ractor.current[:client] = client
        Ractor.current[:logger].info "[Worker #{Ractor.current.name}] client #{Ractor.current[:client].uuid} connected"

        catch :connection_closed do
          loop { SortaRedis::Actor::Worker.message_tick }
        end

        Ractor.current[:client].disconnect!
        Ractor.current[:client] = nil
        Ractor.current[:logger].info "[Worker #{Ractor.current.name}] user #{client.uuid} disconnected"
      end

      def self.message_tick
        client = Ractor.current[:client]
        msg = client.read

        # TODO: сделать модуль для обработку команд уровня воркера, а не хранилища
        client.disconnect! if msg.first.upcase == 'DISCONNECT'

        Ractor.current[:storage].send [Ractor.current, client.uuid, msg].freeze

        client.write(Ractor.receive)
      end

      def self.recreate(*args, name:)
        Ractor.current[:logger].info "[Workers Supervisor] Recreating Worker #{name}"

        puts args.inspect
        new(*args)
      end
    end
  end
end
