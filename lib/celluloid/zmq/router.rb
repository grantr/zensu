module Celluloid
  module ZMQ
    class Router
      include Celluloid::ZMQ

      attr_accessor :identity, :peers, :endpoints

      def initialize(identity=nil, endpoints=[], peer_endpoints=[])
        @identity = identity
        @endpoints = []
        Array(endpoints).each do |endpoint|
          add_endpoint(endpoint)
        end

        @peers = []
        Array(peer_endpoints).each do |peer_endpoint|
          add_peer(peer_endpoint)
        end
      end

      def init_router_socket
        @socket.close if @socket

        @socket = RouterSocket.new
        SocketMonitor.new_link(@socket, "zmq.socket.#{Celluloid::UUID.generate}")
      end

      def add_endpoint(endpoint)
        unless @endpoints.include?(endpoint)
          init_router_socket if @socket.nil?
          async.listen if @endpoints.empty? && @peers.empty?
          begin
            @endpoints << endpoint
            @socket.identity = @identity if @identity
            @socket.bind(endpoint)
          rescue IOError => e
            @socket.close
            raise e
          end
        end
      end

      def remove_endpoint(endpoint)
        if @endpoints.include?(endpoint)
          begin
            @endpoints.delete(endpoint)
            @socket.unbind(endpoint)
          rescue IOError => e
            @socket.close
            raise e
          end
        end
      end

      def clear_endpoints
        @endpoints.dup.each { |endpoint| remove_endpoint(endpoint) }
      end

      def add_peer(peer)
        unless @peers.include?(peer)
          init_router_socket if @socket.nil?
          async.listen if @peers.empty? && @peers.empty?
          begin
            @peers << peer
            @socket.connect(peer)
          rescue IOError => e
            @socket.close
            raise e
          end
        end
      end

      def remove_peer(peer)
        if @peers.include?(peer)
          begin
            @peers.delete(peer)
            @socket.disconnect(peer)
          rescue IOError => e
            @socket.close
            raise e
          end
        end
      end

      def clear_peers
        @peers.dup.each { |peer| remove_peer(peer) }
      end

      def finalize
        @socket.close if @socket
      end

      def write(identity, *parts)
        @socket.write(identity, "", *parts)
      end

      def listen
        loop do
          parts = @socket.read_multipart
          identity = parts.shift
          parts.shift
          dispatch(identity, parts)
        end
      end

      # override this
      def dispatch(identity, parts)
        Logger.debug("received message from #{identity}: #{parts.inspect}")
      end

    end
  end
end
