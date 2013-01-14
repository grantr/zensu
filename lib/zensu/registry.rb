module Zensu
  class Registry < Hash
    attr_accessor :id

    def initialize(id=nil)
      @lock = Mutex.new
      @id = id || Celluloid::UUID.generate
    end

    def get(key)
      @lock.synchronize do
        fetch(key.to_sym, nil)
      end
    end

    def set(key, value)
      @lock.synchronize do
        publish_update(key, fetch(key.to_sym, nil), value)
        store(key.to_sym, value)
      end
    end

    def remove(key)
      @lock.synchronize do
        if deleted = delete(key)
          Celluloid::Notifications.notifier.async.publish("#{topic}.#{key}.remove", id, key, :remove, deleted, nil)
        end
      end
    end

    private :fetch, :store, :delete

    def publish_update(key, previous, current)
      if previous.is_a?(Array) && current.is_a?(Array)
        publish_array_update(key, previous, current)
      else
        Celluloid::Notifications.notifier.async.publish("#{topic}.#{key}.set", id, key, :set, previous, current)
      end
    end

    def publish_array_update(key, previous, current)
      (previous - current).each do |removed|
        Celluloid::Notifications.notifier.async.publish("#{topic}.#{key}.remove_element", id, key, :remove_element, removed, nil)
      end
      (current - previous).each do |added|
        Celluloid::Notifications.notifier.async.publish("#{topic}.#{key}.add_element", id, key, :add_element, nil, added)
      end
    end

    def topic
      "zensu.registry.#{id}"
    end
  end
end

require 'zensu/registry/callbacks'
