module Zensu
  module Server
    class Authenticator
      include Celluloid::ZMQ

      def initialize
        @socket = Celluloid::ZMQ::RepSocket.new

        begin
          @socket.bind("tcp://127.0.0.1:5567") #TODO use config for bind address and port
        rescue IOError
          @socket.close
          raise
        end

        run!
      end

      def run
        while true; handle_message! @socket.read; end
      end

      def finalize
        @socket.close if @socket
      end

      def handle_message(message)
        #TODO handle handshake
        puts "received handshake: #{message}"
        @socket << "handshake2" #TODO send public key, shared key 
      end

    end
  end
end
