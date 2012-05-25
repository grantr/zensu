require 'http_router'

module Zensu
  module API
    class App
      include Celluloid

      def setup_routes
        get "/info" do
          response = requester.request("get_info")
          Zensu.logger.debug "got response from req: #{response}"
          [:ok, MultiJson.dump(response.result)]
        end

        get "/clients" do
          response = requester.request("get_clients")
          Zensu.logger.debug "got response from req: #{response}"
          [:ok, MultiJson.dump(response.result)]
        end

        get "/client/:name" do |env|
          response = requester.request("get_client", name: env['router.params'][:name])
          Zensu.logger.debug "got response from req: #{response}"
          [:ok, MultiJson.dump(response.result)]
        end

        get "/checks" do
          response = requester.request("get_checks")
          Zensu.logger.debug "got response from req: #{response}"
          [:ok, MultiJson.dump(response.result)]
        end

        get "/check/:name" do
          response = requester.request("get_check", name: env['router.params'][:name])
          Zensu.logger.debug "got response from req: #{response}"
          [:ok, MultiJson.dump(response.result)]
        end

        post "/check/request" do
          #TODO
          [:ok, "not implemented"]
        end

        get "/events" do
          response = requester.request("get_events")
          Zensu.logger.debug "got response from req: #{response}"
          [:ok, MultiJson.dump(response.result)]
        end
      end

      def initialize
        @requester_supervisor = RPC::Requester.supervise
        @reel = Reel::Server.supervise Zensu.settings.api.host, Zensu.settings.api.port do |connection|
          dispatch connection
        end

        setup_routes
      end

      def router
        @router ||= HttpRouter.new
      end

      def get(route, &block)
        router.get(route, &block)
      end

      def post(route, &block)
        router.post(route, &block)
      end

      def post(route, &block)
        router.delete(route, &block)
      end

      def requester
        @requester_supervisor.actor
      end

      def dispatch(connection)
        request = connection.request
        if request #TODO why is this occasionally nil?
          Zensu.logger.debug "Client requested: #{request.method} #{request.url}"

          env = Rack::MockRequest.env_for(request.url, method: request.method)
          response = @router.call(env)
          Zensu.logger.debug("response: #{response}")
          connection.respond *response
        end
      end
    end
  end
end
