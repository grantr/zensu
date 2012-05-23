module Zensu
  module RPC
    class Requester
      include Celluloid::ZMQ
      include RPC::Encoding

      def initialize
        @socket = Celluloid::ZMQ::ReqSocket.new

        begin
          Zensu.settings.servers.each do |server|
            @socket.connect("tcp://#{server.host}:#{server.rpc_port}")
          end
        rescue IOError
          @socket.close
          raise
        end
      end

      def finalize
        @socket.close if @socket
      end

      def request(*args)
        request = generate_request(*args)
        Zensu.logger.debug "sending request: #{request}"

        @socket << encode(request)

        # TODO configurable timeout
        @timeout_timer = after(5) { terminate } #TODO log termination
        response = get_response
        @timeout_timer.cancel

        Zensu.logger.debug "got response: #{response}"
        if response.error?
          Zensu.logger.error(response.error)
        else
          handle_response response
        end
      end

      def get_response
        reply = @socket.read
        Zensu.logger.debug("got reply: #{reply}")
        RPC::Response.parse decode(reply)
      end


      def generate_request
        # override in subclasses
      end

      def handle_response(response)
        # override in subclasses
      end
    end
  end
end
