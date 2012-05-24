module Zensu
  module API
    class App
      include Celluloid

      def initialize
        @requester_supervisor = RPC::Requester.supervise
        @reel = Reel::Server.supervise Zensu.settings.api.host, Zensu.settings.api.port do |connection|
          handle connection
        end
      end

      def requester
        @requester_supervisor.actor
      end

      def handle(connection)
        request = connection.request
        if request #TODO why is this occasionally nil?
          response = dispatch_request request
          Zensu.logger.debug("response: #{response}")
          connection.respond *response
        end
      end

      def dispatch_request(request)
        Zensu.logger.debug "Client requested: #{request.method} #{request.url}"

        if request.method == :get && request.url = "/clients"
          response = requester.request("get_clients")
          Zensu.logger.debug "got response from req: #{response}"
          [:ok, MultiJson.dump(response.result)]
        else
          [:ok, "hello, world"]
        end
      end

    end
  end
end
