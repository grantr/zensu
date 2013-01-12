module Zensu
  class Heart
    include Celluloid
    include Zensu::RemoteNotifications

    HEARTBEAT = 1 #TODO setting

    def initialize
      every(HEARTBEAT) { beat }
    end

    def beat
      Logger.trace "beat heart #{Zensu.node.id} #{Time.now.to_i}"
      remote_publish("zensu.heartbeat", Zensu.node.id, Time.now.to_i.to_s)
    end
  end
end
