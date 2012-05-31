module Zensu
  module RPC
    module Dispatch

      def finalize
        handlers.values.each do |handler|
          handler.terminate if handler.alive?
        end
      end

      # :with can be either an actor or an actor class
      def handle(*methods, options)
        handler = options.delete(:with)
        Zensu.logger.debug("handler for #{methods.inspect} is #{handler}")
        handler = handler.is_a?(Celluloid) ? handler : handler.supervise
        Zensu.logger.debug("handler is #{handler}")
        methods.flatten.each do |method|
          handlers[method.to_sym] = handler
        end
      end

      def handler_for(method)
        handler = handlers[method.to_sym]
        if handler
          handler.respond_to?(:actor) ? handler.actor : handler
        end
      end

      def handlers
        @handlers ||= {}
      end
    end
  end
end
