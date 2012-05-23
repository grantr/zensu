module Zensu
  module Server
    class KeepaliveHandler
      include Celluloid

      def initialize

        #every(30) { check }
      end

      def failure_detectors
        @failure_detectors ||= {}
      end

      def failure_detector_for(client)
        @failure_detectors[client] ||= FailureDetector.new(client)
      end

      def handle(message)
        Zensu.logger.debug("handling keepalive: #{message}")
        return
        client = message.client['name']

        failure_detector_for(client).add
      end

      def check
        failure_detectors.each do |client, detector|
          mark_dead(client) if detector.suspicious?
        end
      end

      def mark_dead(client)
        Zensu.logger.debug("marking dead: #{client}")
      end

    end
  end
end
