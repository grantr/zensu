require 'zensu/node'

module Zensu
  class Stethoscope
    include Celluloid
    include Zensu::RemoteNotifications

    attr_accessor :nodes

    def initialize
      @nodes = {}
      remote_subscribe(/^zensu.heartbeat/, :record_heartbeat)
    end

    def record_heartbeat(topic, node_id, heartbeat)
      Logger.trace "recording heartbeat from #{node_id} #{heartbeat}"
      add_node(node_id) unless @nodes.has_key?(node_id)
      @nodes[node_id].beat_heart
    end

    def add_node(node_id)
      @nodes[node_id] ||= Node.new_link(node_id)
    end
  end
end
