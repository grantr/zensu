module Zensu
  module Server
    class Broadcaster
      include Celluloid
      include Zensu::RemoteNotifications
      include Celluloid::Logger

      def broadcast(topic, notification)
        debug "publishing to #{topic}: #{notification}"
        remote_publish("zensu.broadcast.#{topic}", notification)
      end

    end
  end
end
