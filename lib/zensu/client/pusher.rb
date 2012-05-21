module Zensu
  module Client
    class Pusher
      include Celluloid::ZMQ

      include RPC::Encoding

      # plugin actors should inherit from this class.
      # the subscriber actor should be the one creating the plugin classes.

      def initialize
        @socket = PushSocket.new

        begin
          @socket.connect("tcp://127.0.0.1:5566") # TODO config all server addresses and ports, connect to each one
        rescue IOError
          @socket.close
          raise
        end
      end

      def finalize
        @socket.close if @socket
      end

      def check
        push("checking")
      end

      def push(message)
        #TODO receive pushes from handlers and push to servers
        Zensu.logger.debug("pushing: #{message}")
        @socket << encode(RPC::Notification.new('result', {'output' => message}))
      end

    end
  end
end
