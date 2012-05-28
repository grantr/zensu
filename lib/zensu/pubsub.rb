module Zensu
  #TODO this could be a generic celluloid-zmq thing
  module Pubsub
    # any class including this module gets an inproc pub and sub socket per instance
    def initialize(*args)
      super
      setup_pubsub
    end

    def setup_pubsub
      @pubsub = Notifier.supervise
    end

    def pubsub_publish(topic, message)
      @pubsub.actor.publish(topic, message)
    end

    def pubsub_subscribe(topic, &block)
      @pubsub.actor.subscribe(topic, &block)
    end

    class Broker
      include Celluloid::ZMQ

      def initialize
        setup_source
        setup_sink
        run!
      end

      def setup_source
        @sub_socket.close if @sub_socket
        @sub_socket = Celluloid::ZMQ::SubSocket.new

        begin
          @sub_socket.bind("inproc://celluloid-pubsub-source")
          @sub_socket.subscribe("")
        rescue IOError => e
          @sub_socket.close
          raise
        end
      end

      def setup_sink
        @pub_socket.close if @pub_socket
        @pub_socket = Celluloid::ZMQ::PubSocket.new

        begin
          @pub_socket.bind("inproc://celluloid-pubsub-sink")
        rescue IOError => e
          @pub_socket.close
          raise
        end
      end

      def run
        loop do
          topic, message = @sub_socket.read, @sub_socket.read
          @pub_socket.send_multiple([topic, message])
        end
      end

    end

    class Notifier
      include Celluloid::ZMQ

      def initialize
        setup_publisher
        setup_subscriber
        run!
      end


      def setup_publisher
        @pub_socket.close if @pub_socket
        @pub_socket = Celluloid::ZMQ::PubSocket.new

        begin
          @pub_socket.connect("inproc://celluloid-pubsub-source")
        rescue IOError => e
          @pub_socket.close
          raise
        end

      end

      def setup_subscriber
        @sub_socket.close if @sub_socket
        @sub_socket = Celluloid::ZMQ::SubSocket.new

        begin
          @sub_socket.connect("inproc://celluloid-pubsub-sink")
          unless subscriptions.empty?
            subscriptions.each do |topic, subscriptions|
              @sub_socket.subscribe(topic)
            end
          end
        rescue IOError
          @sub_socket.close
          raise
        end
      end

      def publish(topic, message)
        @pub_socket.send_multiple [topic.to_s, Marshal.dump(message)]
      end

      def subscribe(topic, &block)
        @sub_socket.subscribe(topic.to_s)
        subscriptions[topic.to_s] ||= []
        subscriptions[topic.to_s] << block
      end

      def subscriptions
        @subscriptions ||= {}
      end

      def run
        loop do
          topic =   @sub_socket.read
          message = @sub_socket.read

          call_subscriptions_for(topic, message)
        end
      end

      def call_subscriptions_for(topic, message)
        if subscriptions[topic.to_s]
          subscriptions[topic.to_s].each do |subscription|
            subscription.call(Marshal.load(message), topic.to_s)
          end
        end
      end
    end
  end
end
