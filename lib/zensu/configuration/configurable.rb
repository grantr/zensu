module Zensu
  module Configurable

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def config_topic(topic=nil)
        if topic
          @config_topic = topic
        else
          @config_topic
        end
      end

      def config
        # create a new "anonymous" class that will host the compiled reader methods
        @config ||= Class.new(Configuration).new(@_config_topic)
      end

      def configure
        yield config
      end

      def config_accessor(*names)
        options = names.last.is_a?(Hash) ? names.pop : {}

        names.each do |name|
          reader, line = "def #{name}; config.get(:'#{name}'); end", __LINE__
          writer, line = "def #{name}=(value); config.set(:'#{name}', value); end", __LINE__

          singleton_class.class_eval reader, __FILE__, line
          singleton_class.class_eval writer, __FILE__, line
          class_eval reader, __FILE__, line unless options[:instance_reader] == false
          class_eval writer, __FILE__, line unless options[:instance_writer] == false
        end
      end
    end

    def config
      self.class.config
    end
  end
end
