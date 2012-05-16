module Zensu
  module Client
    class Subscriber
      include Celluloid::ZMQ

      def initialize
        @socket = Celluloid::ZMQ::SubSocket.new

        begin
          @socket.connect("tcp://127.0.0.1:5565") # TODO config all server addresses and ports, connect to each one
          @socket.subscribe("") #TODO subscribe to real topics
          #TODO create multiple sockets, one for each topic
        rescue IOError
          @socket.close
          raise
        end

        run!
      end

      def run
        while true; handle_message! @socket.read; end
      end

      def finalize
        @socket.close if @socket
      end

      def handle_message(message)
        #TODO dispatch message properly
        puts "handled broadcast: #{message}"
      end
    end
  end
end
