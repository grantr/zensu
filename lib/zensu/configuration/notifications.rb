module Zensu
  class Configuration
    # on_configure :server do |action, previous, current|
    # end
    #
    # on_configure do |key, action, previous, current|
    # end
    #
    # on_add_element :server, do |previous, current|
    # end
    #
    # cb = on_configure :server, config: Zensu.config do |action, previous, current|
    # end
    #
    # cb.cancel
    module Notifications

      # Contains a config callback.
      class ConfigCallback

        attr_accessor :key, :action, :block

        def initialize(key=nil, action=nil, &block)
          @key = key ? key.to_sym : nil
          @action = action ? action.to_sym : nil
          @block = block
          @active = true
        end

        def call(key, action, previous, current)
          args = []
          args << key if @key.nil?
          args << action if @action.nil?

          args += [previous, current]

          block.call(*args)
        end

        # cancel the callback.
        def cancel
          @active = false
        end

        def active?
          @active
        end

        def subscribed_to?(key, action)
          (@key.nil? || @key == key.to_sym) && (@action.nil? || @action == action.to_sym)
        end
      end

      def on_configure(*args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        key, action = args
        callback = ConfigCallback.new(key, action, &block)
        add_config_callback(callback, options)
        callback
      end

      def on_set(*args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        on_configure(args.first, :set, options, &block)
      end

      def on_remove(*args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        on_configure(args.first, :remove, options, &block)
      end

      def on_add_element(*args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        on_configure(args.first, :add_element, options, &block)
      end

      def on_remove_element(*args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        on_configure(args.first, :remove_element, options, &block)
      end

      def add_config_callback(callback, options)
        config_callbacks << callback
        config = options[:config] || Zensu.config
        topic = [config.topic, callback.key, callback.action].compact.join(".")

        link Celluloid::Notifications.notifier
        Celluloid::Notifications.notifier.subscribe(Celluloid::Actor.current, /^#{topic}/, :dispatch_config_callback)
      end

      def callbacks_for(key, action)
        config_callbacks.select { |cc| cc.active? && cc.subscribed_to?(key, action) }
      end

      def dispatch_config_callback(topic, key, action, previous, current)
        callbacks_for(key, action).each { |cc| cc.call(key, action, previous, current) }
      end

      def config_callbacks
        @config_callbacks ||= []
      end
    end
  end
end
