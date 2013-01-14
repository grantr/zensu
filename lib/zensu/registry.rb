module Zensu
  class Registry < Hash
    # topic to publish updates to
    attr_accessor :topic

    # TODO may be useful to add a uuid to this topic
    def initialize(topic=nil)
      @lock = Mutex.new
      @topic = topic || Celluloid::UUID.generate
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
          Celluloid::Notifications.notifier.async.publish("#{topic}.#{key}.remove", key, :remove, deleted)
        end
      end
    end

    private :fetch, :store, :delete

    def publish_update(key, previous, current)
      if previous.is_a?(Array) && current.is_a?(Array)
        publish_array_update(key, previous, current)
      else
        Celluloid::Notifications.notifier.async.publish("#{topic}.#{key}.set", key, :set, previous, current)
      end
    end

    def publish_array_update(key, previous, current)
      (previous - current).each do |removed|
        Celluloid::Notifications.notifier.async.publish("#{topic}.#{key}.remove_element", key, :remove_element, removed, nil)
      end
      (current - previous).each do |added|
        Celluloid::Notifications.notifier.async.publish("#{topic}.#{key}.add_element", key, :add_element, nil, added)
      end
    end
  end
end

require 'zensu/registry/callbacks'
