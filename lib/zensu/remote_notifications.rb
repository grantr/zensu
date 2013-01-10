require 'celluloid/zmq/pubsub_notifier'

module Zensu
  module RemoteNotifications
    def self.notifier
      Celluloid::Actor[:remote_notifier]
    end

    def remote_publish(pattern, *args)
      Zensu::RemoteNotifications.notifier.publish(pattern, *args)
    end

    def remote_subscribe(pattern, method)
      Zensu::RemoteNotifications.notifier.subscribe(Celluloid::Actor.current, pattern, method)
    end

    def remote_unsubscribe(*args)
      Zensu::RemoteNotifications.notifier.unsubscribe(*args)
    end

    class RemoteNotifier < Celluloid::ZMQ::PubsubNotifier
      #TODO read configuration
    end
  end
end
