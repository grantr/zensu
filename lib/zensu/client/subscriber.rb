module Zensu
  module Client
    class Subscriber
      include Celluloid::ZMQ

      def initialize
        @socket = Celluloid::ZMQ::SubSocket.new

        begin
          Zensu.settings.servers.each do |server|
            @socket.connect("tcp://#{server.host}:#{server.broadcast_port}")
          end
          @socket.subscribe("system") #TODO subscribe to real topics
          #TODO create multiple sockets, one for each topic
        rescue IOError
          @socket.close
          raise
        end

        run!
      end

      def run
        while true
          topic   = @socket.read
          message = @socket.read
          handle_message! message
        end
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
