module Zensu
  module Client
    class Requester
      include Celluloid::ZMQ

      include RPC::Encoding
      
      def self.request(method, options)
        @requester_classes ||= {}
        @requester_classes[method.to_sym] = options[:with]

        define_method(method.to_sym) do |*args|
          process_request @requesters[method.to_sym], *args
        end
      end

      def self.requester_classes
        @requester_classes
      end

      # requesters
      request :handshake, with: RPC::Handshake::Keyslave

      def initialize
        @socket = Celluloid::ZMQ::ReqSocket.new

        begin
          @socket.connect("tcp://127.0.0.1:5567") # TODO config all server addresses and ports, connect to each one
        rescue IOError
          @socket.close
          raise
        end

        start_requesters
      end

      def finalize
        @socket.close if @socket
      end

      def start_requesters
        @requesters = {}
        self.class.requester_classes.each do |method, requester_class|
          @requesters[method] = requester_class.new_link
        end
      end

      def process_request(requester, *args)
        request = requester.request(*args)
        Zensu.logger.debug "sending request: #{request}"
        
        @socket << encode(request)

        # TODO configurable timeout
        @timeout = after(5) { terminate } #TODO log termination
        response = RPC::Response.parse(decode(@socket.read))
        @timeout.cancel

        Zensu.logger.debug "got reply: #{response}"
        requester.handle_response response
      end

    end
  end
end
