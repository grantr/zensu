class Broadcaster
  include Celluloid
  include Zensu::RemoteNotifications

  def broadcast(topic, notification)
    Celluloid::Logger.debug "publishing to #{topic}: #{notification}"
    remote_publish("zensu.broadcast.#{topic}", notification)
  end

end
