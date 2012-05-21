module Zensu
  module Server
    class Puller
      include Celluloid::ZMQ

      include RPC::Encoding

      def initialize
        @socket = PullSocket.new

        begin
          @socket.bind("tcp://127.0.0.1:5566") # TODO config address and port
        rescue IOError
          @socket.close
          raise
        end

        run!
      end

      def run
        while true
          handle_message! decode(@socket.read)
        end
      end

      def finalize
        @socket.close if @socket
      end

      def handle_message(message)
        #TODO dispatch message properly
        Zensu.logger.debug "handled push: #{message}"
      end
    end
  end
end
