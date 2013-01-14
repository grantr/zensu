require 'celluloid/zmq/pubsub_notifier'

module Zensu
  module RemoteNotifications
    def self.notifier
      Celluloid::Actor[:remote_notifier]
    end

    def remote_notifier
      Zensu::RemoteNotifications.notifier
    end

    def remote_publish(pattern, *args)
      Zensu::RemoteNotifications.notifier.publish(pattern, *args)
    end

    def remote_subscribe(pattern, method)
      link remote_notifier
      Zensu::RemoteNotifications.notifier.subscribe(Celluloid::Actor.current, pattern, method)
    end

    def remote_unsubscribe(*args)
      Zensu::RemoteNotifications.notifier.unsubscribe(*args)
    end
  end

  class RemoteNotifier < Celluloid::ZMQ::PubsubNotifier
    include Registry::Callbacks

    def initialize
      super()

      on_update Zensu.config, :servers do |action, previous, current|
        case action
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

      on_set Zensu.config, :broadcast_endpoint do |previous, current|
        add_endpoint(current)
      end

      on_remove Zensu.config, :broadcast_endpoint do |previous, current|
        remove_endpoint(previous)
      end
    end
  end
end
