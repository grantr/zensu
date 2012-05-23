module Zensu
  module RPC
    module Dispatch

      # :with can be either an actor or an actor class
      def handle(*methods, options)
        handler = options.delete(:with)
        handler = handler.is_a?(Celluloid::Actor) ? handler : handler.supervise
        methods.each do |method|
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
