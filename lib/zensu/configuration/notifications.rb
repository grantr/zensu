module Zensu
  class Configuration
    module Notifications
      #TODO should not have to deal with topic. should be able to easily determine what the change was.
      #
      # This method should conceal the details of how Configuration publishes changes
      # and allow including classes to write methods like this:
      # def set_server(action, previous, current)
      def config_subscribe(config_key, method, config=Zensu.config)
        Celluloid::Notifications.notifier.subscribe(Celluloid::Actor.current, /^#{config.topic}.#{config_key}/, method)
      end

      def config_action(topic)
        topic.split(".").last.to_sym
      end
    end
  end
end
