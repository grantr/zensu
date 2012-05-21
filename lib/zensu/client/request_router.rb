module Zensu
  module Client
    class RequestRouter
      include Celluloid::ZMQ

      #TODO this class isn't strictly necessary and may be too many layers of abstraction.
      # Each requester could manage its own req socket.

      include RPC::Encoding
      
      def initialize
        @socket = Celluloid::ZMQ::ReqSocket.new

        begin
          @socket.connect("tcp://127.0.0.1:5567") # TODO config all server addresses and ports, connect to each one
        rescue IOError
          @socket.close
          raise
        end

        # requesters
        request :handshake, with: RPC::Handshake::Keyslave
      end

      def finalize
        @socket.close if @socket
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

      def request(method, options)
        @requesters ||= {}
        @requesters[method.to_sym] = options[:with].supervise

        singleton_class.send(:define_method, method.to_sym) do |*args|
          process_request @requesters[method.to_sym], *args
        end
      end


    end
  end
end
