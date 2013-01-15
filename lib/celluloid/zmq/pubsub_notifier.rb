module Celluloid
  module ZMQ
    class PubsubNotifier < Celluloid::Notifications::Fanout
      include Celluloid::ZMQ

      attr_accessor :peers, :endpoints

      def initialize(endpoints=[], peer_endpoints=[])
        super()

        @endpoints = []
        Array(endpoints).each do |endpoint|
          add_endpoint(endpoint)
        end

        @peers = []
        Array(peer_endpoints).each do |peer_endpoint|
          add_peer(peer_endpoint)
        end
      end

      def init_pub_socket
        @pub.close if @pub

        @pub = PubSocket.new
        SocketMonitor.new_link(@pub, "zmq.socket.#{Celluloid::UUID.generate}")
      end

      def add_endpoint(endpoint)
        unless endpoints.include?(endpoint)
          init_pub_socket if @endpoints.empty?
          begin
            @endpoints << endpoint
            @pub.bind(endpoint)
          rescue IOError => e
            @pub.close
            raise e
          end
        end
      end

      def remove_endpoint(endpoint)
        if @endpoints.include?(endpoint)
          begin
            @endpoints.delete(endpoint)
            @pub.unbind(endpoint)
          rescue IOError => e
            @pub.close
            raise e
          end
        end
      end

      def clear_endpoints
        @endpoints.dup.each { |endpoint| remove_endpoint(endpoint) }
      end

      def init_sub_socket
        @sub.close if @sub

        @sub = SubSocket.new
        SocketMonitor.new_link(@sub, "zmq.socket.#{Celluloid::UUID.generate}")
        @sub.subscribe("")

        #TODO add peers? could end up looping
        async.listen
      end

      def add_peer(peer)
        unless @peers.include?(peer)
          init_sub_socket if @peers.empty?
          begin
            @peers << peer
            @sub.connect(peer)
          rescue IOError => e
            @sub.close
            raise e
          end
        end
      end

      def remove_peer(peer)
        if @peers.include?(peer)
          begin
            @peers.delete(peer)
            @sub.disconnect(peer)
          rescue IOError => e
            @sub.close
            raise e
          end
        end
      end

      def clear_peers
        @peers.dup.each { |peer| remove_peer(peer) }
      end

      def listen
        loop do
          pattern = @sub.read
          args = []
          while @sub.more_parts?
            args << @sub.read
          end
          listeners_for(pattern).each { |s| s.publish(pattern, *args) }
        end
      end

      def publish(pattern, *args)
        @pub.write(pattern, *args) if @pub
      end

      # finalizer :close
      # def close
      #   @pub.close if @pub
      #   @sub.close if @sub
      # end

      def finalize
        @pub.close if @pub
        @sub.close if @sub
      end
    end
  end
end
