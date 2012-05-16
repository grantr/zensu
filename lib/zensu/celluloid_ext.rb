module Celluloid
  module ZMQ
    class SubSocket
      def subscribe(topic)
        unless ::ZMQ::Util.resultcode_ok? @socket.setsockopt(::ZMQ::SUBSCRIBE, topic)
          raise IOError, "couldn't set subscribe: #{::ZMQ::Util.error_string}"
        end
      end
    end
  end
end
