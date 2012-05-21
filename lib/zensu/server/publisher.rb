module Zensu
  module Server
    class Publisher
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

        run!
      end

      def run
        #TODO set up broadcast timers
        publish("system", encode(RPC::Notification.new("ping"))) #DEBUG
        after(5) { run }
      end

      def finalize
        @socket.close if @socket
      end

      def publish(topic, message)
        #TODO send topic first
        Zensu.logger.debug "publishing to #{topic}: #{message}"
        @socket.send_multiple [topic, message]
      end

    end
  end
end
