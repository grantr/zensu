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

        delete "/client/:name" do |env|
          response = requester.request("delete_client", name: env['router.params'][:name])
          Zensu.logger.debug "got response from req: #{response}"
          [:ok, MultiJson.dump(response.result)]
        end

        get "/checks" do
          response = requester.request("get_checks")
          Zensu.logger.debug "got response from req: #{response}"
          [:ok, MultiJson.dump(response.result)]
        end

        get "/check/:name" do |env|
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

        get "/event/:client/:check" do |env|
          response = requester.request("get_event", client: env['router.params'][:client], check: env['router.params'][:check])
          Zensu.logger.debug "got response from req: #{response}"
          [:ok, MultiJson.dump(response.result)]
        end

        post "/event/resolve" do |env|
          #TODO
        end

        get "/stash/*path" do |env|
          path = env['router.params'][:path].join("/")
          response = requester.request("get_stash", path: path)
          Zensu.logger.debug "got response from req: #{response}"
          [:ok, MultiJson.dump(response.result)]
        end

        post "/stash/*path" do |env|
          path = env['router.params'][:path].join("/")
          response = requester.request("post_stash", path: path, body: env['rack.input'].read)
          Zensu.logger.debug "got response from req: #{response}"
          [:ok, MultiJson.dump(response.result)]
        end

        delete "/stash/*path" do |env|
          path = env['router.params'][:path].join("/")
          response = requester.request("delete_stash", path: path)
          Zensu.logger.debug "got response from req: #{response}"
          [:ok, MultiJson.dump(response.result)]
        end

        get "/stashes" do
          response = requester.request("get_stashes")
          Zensu.logger.debug "got response from req: #{response}"
          [:ok, MultiJson.dump(response.result)]
        end

        post "/stashes" do
          #TODO
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

      def delete(route, &block)
        router.delete(route, &block)
      end

      def requester
        @requester_supervisor.actor
      end

      def dispatch(connection)
        request = connection.request
        if request #TODO why is this occasionally nil?
          Zensu.logger.debug "Client requested: #{request.method} #{request.url}"

          env = Rack::MockRequest.env_for(request.url, method: request.method, input: request.body)
          response = @router.call(env)
          Zensu.logger.debug("response: #{response}")
          connection.respond *response
        end
      end
    end
  end
end
