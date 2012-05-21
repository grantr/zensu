module Zensu
  module RPC
    class Requester
      include Celluloid::ZMQ
      include RPC::Encoding

      def initialize
        @socket = Celluloid::ZMQ::ReqSocket.new

        begin
          Zensu.settings.servers.each do |server|
            @socket.connect("tcp://#{server.host}:#{server.reqrep_port}")
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
        @timeout = after(5) { terminate } #TODO log termination
        response = RPC::Response.parse(decode(@socket.read))
        @timeout.cancel

        Zensu.logger.debug "got reply: #{response}"
        handle_response response
      end
    end
  end
end
