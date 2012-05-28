module Zensu
  module RPC
    class Requester
      include Celluloid::ZMQ
      include RPC::Encoding

      def initialize(options={})
        setup_socket

        @timeout = options[:timeout] || 5
      end

      def setup_socket
        @socket.close if @socket
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

        begin
          response = future(:get_response).value(@timeout)
        rescue => e
          if e.message =~ /Timed out/ #TODO better exception from celluloid
            response = RPC::Response.new(nil, "gateway_timeout", request.id)
          end
          setup_socket
          #TODO should this raise?
        end

        Zensu.logger.debug "got response: #{response}"
        if response.error?
          Zensu.logger.error(response.error)
          handle_response response #TODO how to handle errors?
        else
          handle_response response
        end
      end

      def get_response
        reply = @socket.read
        Zensu.logger.debug("got reply: #{reply}")
        RPC::Response.parse decode(reply)
      end

      def generate_request(method, params=nil)
        # override in subclasses
        RPC::Request.new(method, params)
      end

      def handle_response(response)
        response
      end
    end
  end
end
