module Zensu
  module RPC
    class Requester
      include Celluloid::ZMQ
      include RPC::Encoding

      def initialize(options={})
        @socket = Celluloid::ZMQ::ReqSocket.new

        begin
          Zensu.settings.servers.each do |server|
            @socket.connect("tcp://#{server.host}:#{server.rpc_port}")
          end
        rescue IOError
          @socket.close
          raise
        end

        @timeout = options[:timeout] || 5
      end

      def finalize
        @socket.close if @socket
      end

      def request(*args)
        request = generate_request(*args)
        Zensu.logger.debug "sending request: #{request}"

        @socket << encode(request)

        response = future(:get_response).value(@timeout)

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
