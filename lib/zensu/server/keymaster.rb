module Zensu
  module Server
    class Keymaster
      include Celluloid::ZMQ

      include RPC::Encoding
      include RPC::Handshake
      include SSL

      #TODO make this socket a more general request/reply handler. Could be used for other things like:
      # * querying the server for config information
      # * other kinds of queries?
      #
      # The socket is owned by a general request/reply handler that routes to specific handlers based on method.
      # These method handlers don't need to be actors since the req/rep sockets are synchronous.
      # request/response methods and handlers can be defined in the same module.

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
        #TODO add check for new shared key
        while true; handle_message! @socket.read; end
      end

      def finalize
        @socket.close if @socket
      end

      def handle_message(message)
        puts "received handshake: #{message}"
        request = HandshakeRequest.parse(decode(message))
        puts "request object: #{request} #{request.id}"

        if valid_certificate?(request.params['cert'])
          response = encode HandshakeResponse.new(certificate.to_pem, public_encrypt(request.params['cert'], shared_key), request.id)
        else
          #TODO errors
          response = encode HandshakeResponse.new("", "", request.id)
        end
        puts "sending response: #{response}"
        @socket << response 
      end

      def shared_key
        "bacon" #TODO get the shared key from redis
      end

    end
  end
end
