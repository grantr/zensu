module Zensu
  class Heart
    include Celluloid
    include Zensu::RemoteNotifications

    HEARTBEAT = 1 #TODO setting

    def initialize
      every(HEARTBEAT) { beat }
    end

    # heartbeat should include a list of referenceable actors and other things
    # if heartbeat is encrypted, stethoscope should still work but it should ignore any data
    def beat
      Logger.trace "beat heart #{Zensu.node.id} #{Time.now.to_i}"
      remote_publish("zensu.heartbeat", Zensu.node.id, Zensu.config.router_endpoint, Time.now.to_i.to_s)
    end
  end
end
