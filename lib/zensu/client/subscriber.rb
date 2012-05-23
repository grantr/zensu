module Zensu
  module Client
    class Subscriber
      include Celluloid::ZMQ

      include RPC::Encoding
      include RPC::Dispatch

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
        loop do
          topic   = @socket.read
          message = @socket.read
          dispatch! RPC::Notification.parse(decode(message))
        end
      end

      def finalize
        @socket.close if @socket
      end

      def add_pusher(check, options)
        @pushers ||= {}
        Zensu.logger.debug("adding pusher for check: #{check} #{options}")

        if options['command']
          handle check, with: CommandPusher.supervise(check, options)
        else
          handle check, with: Pusher
        end
      end

      def dispatch(message)
        Zensu.logger.debug "handled broadcast: #{message}"
       
        case message.method
        when 'check'
          pusher = handler_for(message.check)
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
