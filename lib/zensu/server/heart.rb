module Zensu
  module Server
    class Heart
      include Celluloid
      include Zensu::Broadcast

      HEARTBEAT = 1 #TODO setting

      def initialize
        every(HEARTBEAT) { beat }
      end

      def beat
        broadcast.publish("zensu.heartbeat", Zensu.id, Time.now.to_i.to_s)
      end
    end
  end
end
