require 'openssl'

module Zensu
  module Client
    class Authenticator
      include Celluloid::ZMQ

      include RPC::Encoding
      include RPC::Handshake

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
        request = encode HandshakeRequest.new("client_name", "client_cert")
        puts "sending request: #{request}"
        @socket << request
        reply = @socket.read
        puts "got reply: #{reply}"
        response = HandshakeResponse.parse(decode(reply))
        #TODO verify server cert and decrypt/store shared key
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
