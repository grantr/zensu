module Zensu
  module Client
    class KeepalivePusher < Pusher

      def initialize
        super

        @timer = every(30) { keepalive }
      end

      #TODO include timestamp and client configuration
      def keepalive
        Zensu.logger.debug("pushing keepalive")
        push "keepalive", "keepalive"
      end
    end
  end
end
