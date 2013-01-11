module Zensu
  module Client
    class Subscriber
      include Celluloid
      include Zensu::RemoteNotifications
      include Celluloid::Logger

      def initialize
        remote_subscribe(/^zensu.broadcast/, :dispatch)
      end

      def dispatch(topic, message)
        debug "handled broadcast: #{topic} #{message}"
      end
    end
  end
end
