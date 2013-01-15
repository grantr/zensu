require 'zensu/node'

module Zensu
  class Stethoscope
    include Celluloid
    include Zensu::RemoteNotifications

    def initialize
      remote_subscribe(/^zensu.heartbeat/, :record_heartbeat)
    end

    def record_heartbeat(topic, node_id, node_address, heartbeat)
      Logger.trace "recording heartbeat from #{node_id} #{heartbeat}"

      #TODO possible race condition from other node sources
      unless node = Zensu.nodes.get(node_id)
        node = Zensu.nodes.set(node_id, Node.new(node_id, node_address))
      end

      node.beat_heart(heartbeat)
    end
  end
end
