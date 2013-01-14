require 'uri'
module Zensu
  class Message
    VERSION = "1"

    attr_accessor :headers
    attr_accessor :version
    attr_accessor :args

    def initialize(headers=[], args=[], version=VERSION)
      @headers = headers
      @args = args
      @version = version
    end

    # Should headers be a single hash or an array?
    def self.parse(parts)
      message = new
      parts = parts.dup
      message.version = parts.shift

      #TODO branch on version here

      while (header = parts.shift) != ""
        message.headers << header
      end

      message.args = parts
    end

    def to_parts
      [
       version,
       *headers.collect(&:to_s),# json
       "",
       *args.collect(&:to_s)] # json
    end
  end

  # This is a low level router class
  class Router
    include Celluloid::ZMQ
    
    attr_accessor :identity, :peers, :endpoints

    def initialize(identity, endpoints=[], peer_endpoints=[])
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
      @socket.identity = @identity
      SocketMonitor.new_link(@socket, "zmq.socket.#{Celluloid::UUID.generate}")
    end

    def add_endpoint(endpoint)
      init_router_socket if @socket.nil?
      async.listen if @endpoints.empty? && @peers.empty?
      begin
        @endpoints << endpoint
        @socket.bind(endpoint)
      rescue IOError => e
        @socket.close
        raise e
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

    def add_peer(endpoint)
      init_router_socket if @socket.nil?
      async.listen if @endpoints.empty? && @peers.empty?
      begin
        @peers << endpoint
        @socket.connect(endpoint)
      rescue IOError => e
        @socket.close
        raise e
      end
    end

    def remove_peer(endpoint)
      if @peers.include?(endpoint)
        begin
          @peers.delete(endpoint)
          @socket.disconnect(endpoint)
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

    def remote_send(identity, *args)
      #TODO headers
      message = Message.new([], args)
      @socket.write(identity, "", *message.to_parts)
    end

    def listen
      loop do
        parts = @socket.read_multipart
        identity = parts.shift
        parts.shift
        message = Message.parse(parts)

        dispatch(identity, message)
      end
    end

    # override this
    def dispatch(identity, message)
      Logger.debug("received message from #{identity}: #{message}")
    end

  end
end
