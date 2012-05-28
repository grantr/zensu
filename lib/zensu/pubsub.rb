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

    class BrokerRunningError < StandardError; end
    class Broker
      include Celluloid

      MUTEX = Mutex.new
      def initialize
        MUTEX.lock
        begin
          if Actor[:broker] && Actor[:broker].alive?
            raise BrokerRunningError
          else
            Actor[:broker] = Actor.current
            run!
          end
        ensure
          MUTEX.unlock rescue nil
        end
      end

      def subscribers
        @subscribers ||= []
      end

      def add_subscriber(subscriber)
        subscribers << subscriber
      end

      def run
        loop do
          message = receive
          subscribers.each do |subscriber|
            if subscriber.alive?
              subscriber.mailbox << message
            else
              subscribers.delete(subscriber)
            end
          end
        end
      end

    end

    class Notifier
      include Celluloid::ZMQ

      trap_exit :broker_died

      def initialize
        start_broker
        run!
      end

      def start_broker
        begin
          Actor[:broker] ||= Broker.new
        rescue BrokerRunningError
        end
        Actor.current.link Actor[:broker]
        Actor[:broker].add_subscriber!(Actor.current)
      end

      def broker_died(actor, reason)
        puts "broker died: #{actor} #{reason}"
      end

      def publish(topic, message)
        Actor[:broker].mailbox << [topic, message]
      end

      def subscribe(topic, &block)
        subscriptions[topic] ||= []
        subscriptions[topic] << block
      end

      def subscriptions
        @subscriptions ||= {}
      end

      def run
        loop do
          topic, message = receive
          call_subscriptions_for(topic, message)
        end
      end

      def call_subscriptions_for(topic, message)
        if subscriptions[topic]
          subscriptions[topic].each do |subscription|
            subscription.call(message, topic)
          end
        end
      end
    end
  end
end
