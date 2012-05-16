require 'openssl'

module Zensu
  module Client
    class Authenticator
      include Celluloid::ZMQ

      def initialize
        @socket = Celluloid::ZMQ::ReqSocket.new

        begin
          @socket.connect("tcp://127.0.0.1:5567") # TODO config all server addresses and ports, connect to each one
        rescue IOError
          @socket.close
          raise
        end
      end

      def finalize
        @socket.close if @socket
      end

      def handshake
        @socket << "handshake1" #TODO send: client id, public key
        reply = @socket.read
        puts "got reply: #{reply}"
        #TODO handshake
      end

      def authenticated?
        !@shared_key.nil?
      end

      def shared_key
        @shared_key
      end

    end
  end
end
