module Zensu
  module Server
    class Broadcaster
      include Celluloid::ZMQ

      include RPC::Encoding

      def initialize
        @socket = Celluloid::ZMQ::PubSocket.new

        begin
          @socket.bind("tcp://127.0.0.1:5565") #TODO use config for bind address and port
        rescue IOError
          @socket.close
          raise
        end

        Zensu.settings.checks.each do |check, options|
          add_check(check, options)
        end
      end

      def finalize
        @socket.close if @socket
      end

      def add_check(check, options)
        interval = options['interval'] || 60
        every(interval) do
          options['subscribers'].each do |subscriber|
            broadcast! subscriber, RPC::Notification.new('check', { 'check' => check })
          end
        end
      end

      def broadcast(topic, notification)
        Zensu.logger.debug "publishing to #{topic}: #{notification}"
        @socket.send_multiple [topic, encode(notification)]
      end

    end
  end
end
