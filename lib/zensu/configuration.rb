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
    include Celluloid::Notifications

    # topic to publish updates to
    attr_accessor :topic

    def initialize(topic=nil)
      @topic = topic || "zensu.config"
    end

    def get(key)
      fetch(key.to_sym, nil)
    end

    def set(key, value)
      publish_update(key, get(key), value)
      store(key.to_sym, value)
    end

    def remove(key)
      if deleted = delete(key)
        #TODO if deleted is an array, publish a remove_element
        publish("#{topic}.#{key}.remove", deleted)
      end
    end

    #TODO make fetch, store, and delete protected

    def publish_update(key, previous, current)
      if previous.is_a?(Array) && current.is_a?(Array)
        publish_array_update(key, previous, current)
      else
        publish("#{topic}.#{key}.set", previous, current)
      end
    end

    def publish_array_update(key, previous, current)
      (previous - current).each do |removed|
        publish([topic, key, "remove_element"].join("."), removed, nil)
      end
      (current - previous).each do |added|
        publish([topic, key, "add_element"].join("."), nil, added)
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
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{key}; get(:'#{key}'); end
        RUBY
      end
    end

  end
end

require 'zensu/configuration/configurable'
require 'zensu/configuration/notifications'
