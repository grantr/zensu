module Zensu
  module Client
    class Pusher
      include Celluloid::ZMQ

      def initialize
        @socket = PushSocket.new

        begin
          @socket.connect("tcp://127.0.0.1:5566") # TODO config all server addresses and ports, connect to each one
        rescue IOError
          @socket.close
          raise
        end
      end

      def finalize
        @socket.close if @socket
      end

      def push(message)
        #TODO receive pushes from handlers and push to servers
        @socket << message
      end

    end
  end
end
