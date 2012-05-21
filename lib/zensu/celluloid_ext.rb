module Celluloid
  module ZMQ
    class ReqSocket
      include WritableSocket
    end

    class RepSocket
      include ReadableSocket
    end

    class SubSocket
      def subscribe(topic)
        unless ::ZMQ::Util.resultcode_ok? @socket.setsockopt(::ZMQ::SUBSCRIBE, topic)
          raise IOError, "couldn't set subscribe: #{::ZMQ::Util.error_string}"
        end
      end
    end

    module WritableSocket
      def send_multiple(messages)
        messages.each_with_index do |message, i|
          if i+1 == messages.size
            flags = 0
          else
            flags = ::ZMQ::SNDMORE
          end

          unless ::ZMQ::Util.resultcode_ok? @socket.send_string(message, flags)
            raise IOError, "error sending 0MQ message: #{::ZMQ::Util.error_string}"
          end
        end

        messages
      end
    end
  end
end
