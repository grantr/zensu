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

        handle :keepalive, with: KeepaliveHandler

        run!
      end

      def run
        while true
          message = @socket.read
          dispatch! RPC::Notification.parse(decode(message))
        end
      end

      def finalize
        @socket.close if @socket
      end

      def dispatch(message)
        Zensu.logger.debug "handled push: #{message}"

        handler = handler_for(message.method)
        if handler
          handler.handle(message)
        else
          Zensu.logger.warn "unknown push method: #{message.method}"
        end
      end
    end
  end
end
