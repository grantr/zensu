module Zensu
  module Client
    class Pusher
      include Celluloid::ZMQ

      include RPC::Encoding


      def initialize
        @socket = PushSocket.new

        begin
          Zensu.settings.servers.each do |server|
            @socket.connect("tcp://#{server.host}:#{server.results_port}")
          end
        rescue IOError
          @socket.close
          raise
        end
      end

      def finalize
        @socket.close if @socket
      end

      def push(method, result)
        #TODO receive pushes from handlers and push to servers
        Zensu.logger.debug("pushing: #{method} #{result}")
        @socket << encode(RPC::Notification.new(method, result))
      end
    end

    # TODO plugin actors should inherit from this class.
    # the subscriber actor should be the one creating the plugin classes.
    class CheckResultPusher < Pusher

      def initialize(check, options={})
        super()

        @check = check

        if options['standalone']
          @interval = options['interval'] || Zensu.settings.default_check_interval
          run!
        end
      end

      def run
        check
        after(@interval) { run }
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
        super("result", result)
      end

    end
  end
end
