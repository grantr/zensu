module Zensu
  module Server
    class Puller
      include Celluloid::ZMQ

      include RPC::Encoding
      include RPC::Dispatch

      def initialize
        @socket = PullSocket.new

        begin
          @socket.bind("tcp://#{Zensu.settings.server.host}:#{Zensu.settings.server.results_port}")
        rescue IOError
          @socket.close
          raise
        end

        handle :keepalive, with: KeepaliveHandler
        handle :result, with: CheckResultHandler

        async.run
      end

      def run
        loop do
          message = @socket.read
          async.dispatch RPC::Notification.parse(decode(message))
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
