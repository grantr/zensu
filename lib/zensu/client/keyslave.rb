module Zensu
  module Client
    class Keyslave
      include Celluloid::ZMQ

      include RPC::Encoding
      include RPC::Handshake
      include SSL

      #TODO make this a state machine that transitions when key becomes valid/invalid

      def initialize
        @socket = Celluloid::ZMQ::ReqSocket.new

        begin
          @socket.connect("tcp://127.0.0.1:5567") # TODO config all server addresses and ports, connect to each one
        rescue IOError
          @socket.close
          raise
        end

        run!
      end

      def finalize
        @socket.close if @socket
      end

      def run
        #TODO retry if handshake failed
        handshake
      end

      def handshake
        #TODO send client cert
        request = encode HandshakeRequest.new("client_name", certificate.to_pem)
        puts "sending request: #{request}"
        @socket << request
        #TODO handle timeouts
        # crash after timing out
        reply = @socket.read
        puts "got reply: #{reply}"
        response = HandshakeResponse.parse(decode(reply))
        

        if valid_certificate?(response.result['cert'])
          @shared_key = private_decrypt(private_key, response.result['shared_key'])
        else
          @shared_key = nil
          # TODO self destruct or try again later
        end
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
