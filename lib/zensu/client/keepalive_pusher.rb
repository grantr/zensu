module Zensu
  module Client
    class KeepalivePusher < Pusher

      #TODO this should only send a keepalive if there were no pushes for 30 seconds.
      # Every push should reset the keepalive timer.

      def initialize
        super

        run!
      end

      def run
        check
        after(30) { run }
      end

      def check
        push "keepalive"
      end
    end
  end
end
