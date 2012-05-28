module Zensu
  #TODO this could be a generic celluloid-zmq thing
  module Pubsub
    # any class including this module gets an inproc pub and sub socket per instance
    #
    # TODO run_pubsub! as a loop hangs
    # exit hangs indefinitely
    
    def initialize(*args)
      super
      setup_pubsub_publisher
      setup_pubsub_subscriber
      # run_pubsub!
    end

    def setup_pubsub_publisher
      @pubsub_pub_socket.close if @pubsub_pub_socket
      @pubsub_pub_socket = Celluloid::ZMQ::PubSocket.new

      begin
        @pubsub_pub_socket.bind("inproc://celluloid-pubsub")
      rescue IOError
        @pubsub_pub_socket.close
        raise
      end
        
    end

    def setup_pubsub_subscriber
      @pubsub_sub_socket.close if @pubsub_sub_socket
      @pubsub_sub_socket = Celluloid::ZMQ::SubSocket.new
      
      begin
        @pubsub_sub_socket.connect("inproc://celluloid-pubsub")
        unless pubsub_subscriptions.empty?
          pubsub_subscriptions.each do |topic, subscriptions|
            @pubsub_sub_socket.subscribe(topic)
          end
        end
      rescue IOERROR
        @pubsub_sub_socket.close
        raise
      end
    end

    def pubsub_publish(topic, message)
      @pubsub_pub_socket.send_multiple [topic.to_s, Marshal.dump(message)]
    end

    def pubsub_subscribe(topic, &block)
      @pubsub_sub_socket.subscribe(topic.to_s)
      pubsub_subscriptions[topic.to_s] ||= []
      pubsub_subscriptions[topic.to_s] << block
    end

    def pubsub_subscriptions
      @pubsub_subscriptions ||= {}
    end

    def run_pubsub
      puts "running pubsub"
      #loop do
        puts "waiting for a message"
        topic =   @pubsub_sub_socket.read
        message = @pubsub_sub_socket.read
       
        call_subscriptions_for(topic, message)
      #end
    end

    def call_subscriptions_for(topic, message)
      if pubsub_subscriptions[topic.to_s]
        pubsub_subscriptions[topic.to_s].each do |subscription|
          subscription.call(Marshal.load(message), topic.to_s)
        end
      end
    end
  end
end
