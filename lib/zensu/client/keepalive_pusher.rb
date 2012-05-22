module Zensu
  module Client
    class KeepalivePusher < Pusher

      #TODO this should only send a keepalive if there were no pushes for 30 seconds.
      # Every push should reset the keepalive timer.
      # TODO every message received by the server should count as a keepalive 

      def initialize
        super

        @timer = every(30) { keepalive }
      end

      def timer
        @timer
      end

      #TODO include timestamp and client configuration
      def keepalive
        Zensu.logger.debug("pushing keepalive")
        push "keepalive", "keepalive"
      end
    end
  end
end
