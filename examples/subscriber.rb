class Subscriber
  include Celluloid
  include Zensu::RemoteNotifications

  def initialize
    remote_subscribe(/^zensu.broadcast/, :dispatch)
  end

  def dispatch(topic, message)
    Celluloid::Logger.debug "handled broadcast: #{topic} #{message}"
  end
end
