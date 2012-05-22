module Zensu
  module Client
    class Pusher
      include Celluloid::ZMQ

      include RPC::Encoding

      # plugin actors should inherit from this class.
      # the subscriber actor should be the one creating the plugin classes.

      def initialize(check, options={})
        @socket = PushSocket.new

        begin
          @socket.connect("tcp://127.0.0.1:5566") # TODO config all server addresses and ports, connect to each one
        rescue IOError
          @socket.close
          raise
        end

        @check = check

        if options['standalone']
          @interval = options['interval'] || Zensu.settings.default_check_interval
          run!
        end
      end

      def finalize
        @socket.close if @socket
      end

      def run
        while true
          check
          after(@interval) { check }
        end
      end

      def check
        push("checking")
      end

      #TODO result format:
      #  client:
      #    name:
      #  check:
      #    name:
      #    status:
      #    duration:
      #    output:
      #    handle: boolean
      #
      def push(result)
        #TODO receive pushes from handlers and push to servers
        Zensu.logger.debug("pushing: #{result}")
        @socket << encode(RPC::Notification.new(@check, result))
      end

    end
  end
end
