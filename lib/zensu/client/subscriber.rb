module Zensu
  module Client
    class Subscriber
      include Celluloid::ZMQ

      include RPC::Encoding

      #TODO supervise plugin actors (pushers)

      def initialize
        @socket = Celluloid::ZMQ::SubSocket.new

        begin
          Zensu.settings.servers.each do |server|
            @socket.connect("tcp://#{server.host}:#{server.broadcast_port}")
          end
        rescue IOError
          @socket.close
          raise
        end

        @socket.subscribe("system")
        Zensu.settings.client.subscriptions.each do |subscription|
          @socket.subscribe(subscription)
        end

        Zensu.settings.checks.each do |check, options|
          add_pusher(check, options)
        end

        run!
      end

      def run
        while true
          topic   = @socket.read
          message = @socket.read
          handle_notification! RPC::Notification.parse(decode(message))
        end
      end

      def finalize
        @socket.close if @socket
      end

      def add_pusher(check, options)
        @pushers ||= {}
        @pushers[check.to_sym] = Pusher.supervise
      end

      def pusher_for(check)
        @pushers[check.to_sym].actor if @pushers[check.to_sym]
      end

      def handle_notification(message)
        #TODO dispatch message properly
        Zensu.logger.debug "handled broadcast: #{message}"
       
        case message.method
        when 'check'
          pusher = pusher_for(message.check)
          if pusher
            pusher.check
          else
            Zensu.logger.warn "Got unknown check #{message.check}"
          end
        end
      end
    end
  end
end
