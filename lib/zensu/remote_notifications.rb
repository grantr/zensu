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
  end

  class RemoteNotifier < Celluloid::ZMQ::PubsubNotifier
    include Configuration::Notifications
    include Celluloid::Logger

    def initialize
      super()
      config_subscribe(:servers, :set_servers)
      config_subscribe(:broadcast_endpoint, :set_endpoint)
    end

    def set_servers(topic, previous, current)
      case config_action(topic)
      when :set
        clear_peers
        current.each { |endpoint| add_peer(endpoint) }
      when :remove_element
        remove_peer(previous)
      when :add_element
        add_peer(current)
      when :remove
        clear_peers
      end
    end

    def set_endpoint(topic, previous, current)
      case config_action(topic)
      when :set
        add_endpoint(current)
      when :remove
        remove_endpoint(previous)
      end
    end
  end
end
