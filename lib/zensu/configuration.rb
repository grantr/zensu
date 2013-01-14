# require 'active_support/configurable'
module Zensu
  # how should configuration work?
  #
  # should be globally accessible
  # should provide a module to give actors methods for conveniently reading and writing config vars
  # should be configurable with ruby
  # should maintain json config compatibility as much as practical
  # should allow for configuration hooks like railties
  # should allow for subscribing to the values of config vars (by publishing changes)
  #
  # ActiveSupport::Configurable is interesting - config_accessor is a good idea
  class Configuration < Hash
    # topic to publish updates to
    attr_accessor :topic

    # TODO may be useful to add a uuid to this topic
    def initialize(topic=nil)
      @mutex = Mutex.new
      @topic = topic || "zensu.config"
    end

    def get(key)
      @mutex.synchronize do
        fetch(key.to_sym, nil)
      end
    end

    def set(key, value)
      @mutex.synchronize do
        publish_update(key, get(key), value)
        store(key.to_sym, value)
      end
    end

    def remove(key)
      @mutex.synchronize do
        if deleted = delete(key)
          Celluloid::Notifications.notifier.async.publish("#{topic}.#{key}.remove", key, :remove, deleted)
        end
      end
    end

    #TODO make fetch, store, and delete protected

    #TODO key and action should be sent as arguments as well as the topic
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

    def method_missing(name, *args)
      if name.to_s =~ /(.*)=$/
        set($1, args.first)
      else
        get(name.to_sym)
      end
    end

    def respond_to?(name)
      true
    end

    def compile_methods!
      self.class.compile_methods!(keys)
    end

    # compiles reader methods so we don't have to go through method_missing
    def self.compile_methods!(keys)
      keys.compact.reject { |m| method_defined?(m) }.each do |key|
        # only compile keys that are valid methods
        # this rejects a few technically valid methods, but that's probably ok
        # to allow ALL valid methods, use key.inspect !~ /[@$"]/
        # Symbol will quote identifiers that are not valid (plus instance and global vars)
        if key =~ /^[A-Za-z]\w*$/
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{key}; get(:'#{key}'); end
          RUBY
        end
      end
    end

  end
end

require 'zensu/configuration/configurable'
require 'zensu/configuration/notifications'
