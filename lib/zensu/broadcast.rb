module Zensu
  module Broadcast
    def broadcast
      Celluloid::Actor[:broadcast_notifier]
    end
  end
end
