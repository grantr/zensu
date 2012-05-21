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

        Zensu.logger.debug "got reply: #{response}"
        handle_response response
      end

      def get_response
        RPC::Response.parse decode(@socket.read)
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
