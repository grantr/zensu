module Zensu
  module Server
    class KeepaliveHandler
      include Celluloid

      include Persistence

      def initialize

        every(30) { check }
      end

      def failure_detectors
        @failure_detectors ||= {}
      end

      def failure_detector_for(client)
        @failure_detectors[client] ||= FailureDetector.new(client)
      end

      def handle(message)
        Zensu.logger.debug("handling keepalive: #{message}")
        client = message.client['name']

        #TODO pipeline
        persister.set client_key_for(client), MultiJson.dump(message.client)
        persister.sadd(clients_key, client)

        failure_detector_for(client).add
      end

      def check
        Zensu.logger.debug("checking detectors")
        failure_detectors.each do |client, detector|
          mark_dead(client) if detector.suspicious?
        end
      end

      def mark_dead(client)
        Zensu.logger.debug("marking dead: #{client}")
      end
      
      def client_key_for(client)
        "client:#{client}"
      end

      def clients_key
        "clients"
      end

    end
  end
end
