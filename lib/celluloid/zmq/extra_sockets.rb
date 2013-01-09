module Celluloid
  module ZMQ
    module ReadableSocket
      extend Forwardable

      # Multiparts message ?
      def_delegator :@socket, :more_parts?
    end

    # DealerSockets are like ReqSockets but more flexible
    class DealerSocket < Socket
      include ReadableSocket
      include WritableSocket

      def initialize
        super :dealer
      end
    end

    # RouterSockets are like RepSockets but more flexible
    class RouterSocket < Socket
      include ReadableSocket
      include WritableSocket

      def initialize
        super :router
      end
    end
  end
end
