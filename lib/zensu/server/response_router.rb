module Zensu
  module Server
    class ResponseRouter
      include Celluloid::ZMQ

      include RPC::Encoding      
      
      def initialize
        @socket = Celluloid::ZMQ::RepSocket.new

        begin
          @socket.bind("tcp://127.0.0.1:5567") #TODO use config for bind address and port
        rescue IOError
          @socket.close
          raise
        end

        # responders
        respond_to :handshake, with: RPC::Handshake::Keymaster

        run!
      end

      def run
        while true
          request = @socket.read
          Zensu.logger.debug "received request: #{request}"
          #TODO validate request
          dispatch! RPC::Request.parse(decode(request))
        end
      end

      def finalize
        @socket.close if @socket
      end

      def dispatch(request)
        responder = responder_for(request)
        if responder
          response = responder.respond(request)
        else
          response = RPC::Response.new(nil, "Unknown method", request.id)
        end
        Zensu.logger.debug "sending response: #{response}"
        @socket << encode(response)
      end

      def respond_to(method, options)
        @responders ||= {}
        @responders[method.to_sym] = options[:with].supervise
      end

      def responder_for(request)
        @responders[request.method.to_sym].actor
      end

      def responders
        @responders
      end

    end
  end
end
