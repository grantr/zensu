module Zensu
  module RPC
    module Dispatch

      def handle(method, options)
        handler = options.delete(:with)
        if handler.is_a?(Celluloid::Actor)
          handlers[method.to_sym] = handler
        else
          handlers[method.to_sym] = handler.supervise
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
