require 'celluloid/zmq/router'
require 'zensu/message'

module Zensu
  class Router < Celluloid::ZMQ::Router
    include Registry::Callbacks

    def initialize(*args)
      super

      on_set Zensu.config, :router_endpoint do |previous, current|
        add_endpoint(current)
      end

      on_remove Zensu.config, :router_endpoint do |previous, current|
        remove_endpoint(previous)
      end

      on_set Zensu.nodes do |key, previous, current|
        add_peer(current.address)
      end

      on_remove Zensu.nodes do |key, previous, current|
        remove_peer(previous.address)
      end
    end

    def request(node, actor, method, *args)
      message = Message.new(nil, [], [actor.name, method, *args])
      write(node.id, message.to_parts)
    end

    def dispatch(identity, parts)
      message = Message.parse(parts)
      Logger.debug "received from #{identity}: #{message.inspect}"
      write(identity, Message.new(message.id, [], ["reply", "reply", 1]).to_parts)
    end

  end
end
