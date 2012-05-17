module Zensu
  module Server
    class Authenticator
      include Celluloid::ZMQ

      include RPC::Encoding
      include RPC::Handshake

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
        request = HandshakeRequest.parse(decode(message))
        puts "request object: #{request} #{request.id}"
        response = encode HandshakeResponse.new("server_cert", 'the_key', request.id)
        puts "sending response: #{response}"
        @socket << response 
      end

    end
  end
end
