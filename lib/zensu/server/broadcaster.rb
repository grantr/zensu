module Zensu
  module Server
    class Broadcaster
      include Celluloid
      include Zensu::RemoteNotifications

      def broadcast(topic, notification)
        Logger.debug "publishing to #{topic}: #{notification}"
        remote_publish("zensu.broadcast.#{topic}", notification)
      end

    end
  end
end
