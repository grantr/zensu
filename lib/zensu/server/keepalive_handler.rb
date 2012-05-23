module Zensu
  module Server
    module KeepaliveHandler
      include Celluloid

      def initialize

        every(30) { check }
      end

      def failure_detectors
        @failure_detectors ||= {}
      end

      def failure_detector_for(client)
        @failure_detectors[client] ||= FailureDetector.new
      end

      def handle(message)
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
