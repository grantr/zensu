require 'celluloid/zmq/router'
require 'zensu/message'

module Zensu
  class Router < Celluloid::ZMQ::Router
    include Registry::Callbacks

    def initialize(*args)
      super

      on_set Zensu.node, :id do |previous, current|
        @identity = current
        # if there are already bound endpoints, they must be rebound
        # to get the new identity
        unless @endpoints.empty?
          endpoints = @endpoints.dup
          clear_endpoints
          endpoints.each { |endpoint| add_endpoint(endpoint) }
        end
      end

      on_set Zensu.config, :router_endpoint do |previous, current|
        add_endpoint(current)
      end

      on_remove Zensu.config, :router_endpoint do |previous, current|
        remove_endpoint(previous)
      end

      on_update Zensu.nodes do |key, action, previous, current|
        case action
        when :set
          Logger.debug "adding peer: #{key} #{current}"
          add_peer(current.address)
        when :remove
          remove_peer(previous.address)
        end
      end
    end

    # create a condition variable in a hash on request id, and wait on it.
    # TODO this should be in the actor instead of the router
    def request(node, name, method, *args)
      @requests = {}
      request = Message.new(nil, [], [name, method, *args])
      @requests[request.id] = Condition.new
      write(node.id, request.to_parts)
      result = @requests[request.id].wait
      
    end

    # dispatch should look to see if there is a condition var waiting on this request id. if so, broadcast the response. if not, what?
    def dispatch(identity, parts)
      message = Message.parse(parts)
      Logger.debug "received from #{identity}: #{message.inspect}"
      if @requests && @requests[message.id]
        @requests[message.id].broadcast(message)
      else
        write(identity, Message.new(message.id, [], ["reply", "reply", 1]).to_parts)
      end
    end

  end
end
