require 'http_router'

module Zensu
  module API
    class App
      include Celluloid
      #TODO use octarine instead

      def setup_routes
        get "/info" do
          requester.request("get_info")
        end

        get "/clients" do
          requester.request("get_clients")
        end

        get "/client/:name" do |env|
          Zensu.logger.debug("in client name")
          response = requester.request("get_client", name: env['router.params'][:name])
          Zensu.logger.debug("client response is: #{response}")
          response
        end

        delete "/client/:name" do |env|
          requester.request("delete_client", name: env['router.params'][:name])
        end

        get "/checks" do
          requester.request("get_checks")
        end

        get "/check/:name" do |env|
          requester.request("get_check", name: env['router.params'][:name])
        end

        post "/check/request" do
          #TODO
          [:ok, "not implemented"]
        end

        get "/events" do
          requester.request("get_events")
        end

        get "/event/:client/:check" do |env|
          requester.request("get_event", client: env['router.params'][:client], check: env['router.params'][:check])
        end

        post "/event/resolve" do |env|
          #TODO
        end

        get "/stash/*path" do |env|
          path = env['router.params'][:path].join("/")
          requester.request("get_stash", path: path)
        end

        post "/stash/*path" do |env|
          path = env['router.params'][:path].join("/")
          requester.request("post_stash", path: path, body: env['rack.input'].read)
        end

        delete "/stash/*path" do |env|
          path = env['router.params'][:path].join("/")
          requester.request("delete_stash", path: path)
        end

        get "/stashes" do
          requester.request("get_stashes")
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
        # TODO this is required because http_router assumes you are returning a rack response array
        @router ||= Class.new(HttpRouter) do
          def pass_on_response(response)
            false
          end
        end.new
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
          Zensu.logger.debug("recognized: #{@router.recognize(env)}")
          response = @router.call(env)
          Zensu.logger.debug("done with router call")

          Zensu.logger.debug("response: #{response}")
          case response
          when RPC::Response
            if response.success?
              #TODO de-uglify this
              status = (response.result.respond_to?(:has_key?) && response.result['status']) ? response.result['status'].to_sym : :ok
              connection.respond status, MultiJson.dump(response.result)
            else
              connection.respond status_symbol(response.error), error_body(response.error)
            end
          else
            # response from http_router
            connection.respond status_symbol(response[0]), error_body(response[0])
          end
        end
      end

      def status_symbol(status)
        status.is_a?(Fixnum) ? Http::Response::STATUS_CODES[status].downcase.gsub(/\s|-/, '_').to_sym : status.to_sym
      end

      def error_body(error)
        code = error.is_a?(Fixnum) ? error : Http::Response::SYMBOL_TO_STATUS_CODE[error.to_sym]
        description = Http::Response::STATUS_CODES[code]
        [code, description].join(" ")
      end
    end
  end
end
