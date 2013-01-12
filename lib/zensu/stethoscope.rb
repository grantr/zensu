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
      @nodes[node_id] ||= Node.new_link(node_id)
      @nodes[node_id].beat_heart
    end
  end
end
