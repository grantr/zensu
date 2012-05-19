module Zensu
  module Server
    class Responder
      include Celluloid::ZMQ

      include RPC::Encoding      
      
      def self.handle(method, options)
        @handler_classes ||= {}
        @handler_classes[method.to_sym] = options[:with]
      end

      def self.handler_classes
        @handler_classes
      end

      # handlers
      handle :handshake, with: RPC::Handshake::Keymaster

      def initialize
        @socket = Celluloid::ZMQ::RepSocket.new

        begin
          @socket.bind("tcp://127.0.0.1:5567") #TODO use config for bind address and port
        rescue IOError
          @socket.close
          raise
        end

        start_handlers

        run!
      end

      def start_handlers
        @handlers = {}
        self.class.handler_classes.each do |method, handler_class|
          @handlers[method] = handler_class.supervise
        end
      end

      def run
        while true
          request = @socket.read
          Zensu.logger.debug "received request: #{request}"
          #TODO validate request
          dispatch RPC::Request.parse(decode(request))
        end
      end

      def finalize
        @socket.close if @socket
      end

      def dispatch(request)
        handler = handler_for(request)
        if handler
          response = handler.respond(request)
        else
          #TODO respond with unknown method error
        end
        Zensu.logger.debug "sending response: #{response}"
        @socket << encode(response)
      end

      def handler_for(request)
        @handlers[request.method.to_sym]
      end

    end
  end
end
