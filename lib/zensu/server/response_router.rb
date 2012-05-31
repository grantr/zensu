module Zensu
  module Server
    class ResponseRouter
      include Celluloid::ZMQ

      include RPC::Encoding
      include RPC::Dispatch

      def initialize
        @socket = Celluloid::ZMQ::RepSocket.new

        begin
          @socket.bind("tcp://#{Zensu.settings.server.host}:#{Zensu.settings.server.rpc_port}") #TODO use config for bind address and port
        rescue IOError
          @socket.close
          raise
        end

        # responders
        handle :handshake, with: Keymaster

        handle APIResponder::IMPLEMENTED_METHODS, with: APIResponder

        run!
      end

      def run
        loop do
          request = @socket.read
          Zensu.logger.debug "received request: #{request}"
          #TODO validate request
          dispatch! RPC::Request.parse(decode(request))
        end
      end

      def finalize
        super
        @socket.close if @socket
      end

      def dispatch(request)
        handler = handler_for(request.method)
        if handler
          response = handler.respond(request)
        else
          response = RPC::Response.new(nil, :method_not_allowed, request.id)
        end
        Zensu.logger.debug "sending response: #{response}"
        @socket << encode(response)
      end

    end
  end
end
