module Zensu
  class Registry
    # on_update registry, :servers do |action, previous, current|
    # end
    #
    # on_update registry do |key, action, previous, current|
    # end
    #
    # on_add_element registry, :servers do |previous, current|
    # end
    #
    # on_set registry do |key, previous, current|
    #
    # cb = on_update registry, :servers do |action, previous, current|
    # end
    # cb.cancel
    module Callbacks

      class Callback

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

      # registry, key, action, options
      def on_update(registry, key=nil, action=nil, options={}, &block)
        callback = Callback.new(key, action, &block)
        add_registry_callback(registry, callback, options)
        callback
      end

      def on_set(registry, key=nil, options={}, &block)
        on_update(registry, key, :set, options, &block)
      end

      def on_remove(registry, key=nil, options={}, &block)
        on_update(registry, key, :remove, options, &block)
      end

      def on_add_element(registry, key=nil, options={}, &block)
        on_update(registry, key, :add_element, options, &block)
      end

      def on_remove_element(registry, key=nil, options={}, &block)
        on_update(registry, key, :remove_element, options, &block)
      end

      def add_registry_callback(registry, callback, options)
        raise ArgumentError, "must provide a registry" if registry.nil?

        registry_callbacks[registry.id] << callback
        topic = [registry.topic, callback.key, callback.action].compact.join(".")

        link Celluloid::Notifications.notifier
        Celluloid::Notifications.notifier.subscribe(Celluloid::Actor.current, /^#{topic}/, :dispatch_registry_callback)

        # There is a potential race condition here. if the registry is updated
        # between the subscribe and the initial set, the callback will fire twice.
        # callbacks should be idempotent if possible.
        if options[:initial_set] != false
          keys = callback.key ? [callback.key] : registry.keys
          keys.each do |key|
            if registry.has_key?(callback.key) && callback.subscribed_to?(key, :set)
              cc.call(key, :set, registry.get(callback.key), registry.get(callback.key))
            end
          end
        end
      end

      def registry_callbacks_for(registry_id, key, action)
        registry_callbacks[registry_id].select { |cc| cc.active? && cc.subscribed_to?(key, action) }
      end

      def dispatch_registry_callback(topic, registry_id, key, action, previous, current)
        registry_callbacks_for(registry_id, key, action).each { |cc| cc.call(key, action, previous, current) }
      end

      def registry_callbacks
        @registry_callbacks ||= Hash.new { |k, v| k[v] = [] }
      end
    end
  end
end
