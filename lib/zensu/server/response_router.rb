module Zensu
  module Server
    class ResponseRouter
      include Celluloid::ZMQ

      include RPC::Encoding
      include RPC::Dispatch

      def initialize
        @socket = Celluloid::ZMQ::RepSocket.new

        begin
          @socket.bind("tcp://127.0.0.1:#{Zensu.settings.server.rpc_port}") #TODO use config for bind address and port
        rescue IOError
          @socket.close
          raise
        end

        # responders
        handle :handshake, with: Keymaster

        #TODO api handlers
        # the http api should use this rpc channel instead of talking to redis directly.
        # possible methods handled:
        # api:
        #   get   /info
        #   get   /clients
        #   get   /client/:name
        #   del   /client/:name
        #   get   /checks
        #   get   /check/:name
        #   post  /check/request
        #   get   /events
        #   get   /event/:client/:check
        #   post  /event/resolve
        #   post  /stash/*
        #   get   /stash/*
        #   del   /stash/*
        #   get   /stashes
        #   post  /stashes
        #

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
        @socket.close if @socket
      end

      def dispatch(request)
        handler = handler_for(request.method)
        if handler
          response = handler.respond(request)
        else
          response = RPC::Response.new(nil, "Unknown method", request.id)
        end
        Zensu.logger.debug "sending response: #{response}"
        @socket << encode(response)
      end

    end
  end
end
