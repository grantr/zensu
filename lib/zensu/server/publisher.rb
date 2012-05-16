module Zensu
  module Server
    class Publisher
      include Celluloid::ZMQ

      def initialize
        @socket = Celluloid::ZMQ::PubSocket.new

        begin
          @socket.bind("tcp://127.0.0.1:5565") #TODO use config for bind address and port
        rescue IOError
          @socket.close
          raise
        end

        run!
      end

      def run
        #TODO set up broadcast timers
        publish("hi!") #DEBUG
        after(5) { run }
      end

      def finalize
        @socket.close if @socket
      end

      def publish(message)
        #TODO send topic first
        puts "publishing: #{message}"
        @socket << message
      end

    end
  end
end
