require 'time'

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
        params = {
          'client'    => Zensu.settings.client.to_hash,
          'timestamp' => Time.now.utc.iso8601
        }
        push "keepalive", params
      end
    end
  end
end
