require 'zensu/client/failure_detector'

module Zensu
  module Client
    class Stethoscope
      include Celluloid
      include Zensu::RemoteNotifications

      def initialize
        @failure_detectors = {}
        remote_subscribe(/^zensu.heartbeat/, :record_heartbeat)
      end

      #? Should this use subscriptions to route? We know the possible servers
      # in advance. If server names were predictable, we could just start a
      # failure detector for each one at boot.
      def record_heartbeat(topic, server_id, heartbeat)
        Logger.trace "recording heartbeat from #{server_id} #{heartbeat}"
        @failure_detectors[server_id] ||= FailureDetector.new_link(server_id)
        @failure_detectors[server_id].add(Time.now.to_i)
      end
    end
  end
end
