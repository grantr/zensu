module Zensu
  module Server
    class APIResponder < RPC::Responder
      include Persistence

      IMPLEMENTED_METHODS = [
        :get_info,
        :get_clients,
        :get_client,
        :delete_client,
        :get_checks,
        :get_check,
        :post_check_request,
        :get_events,
        :get_event,
        :post_event_resolve,
        :post_stash,
        :get_stash,
        :delete_stash,
        :get_stashes,
        :post_stashes
      ]

      def get_info(request)
        {
          'sensu' => {
            'version' => Zensu::VERSION
          },
          'health' => {
            'redis' => 'ok', #TODO
            'rabbitmq' => 'ok' #TODO what to do with this?
            #TODO add server healths
          }
        }
      end

      def get_clients(request)
        persister.smembers('clients').collect do |client|
          MultiJson.load persister.get("client:#{client}")
        end
      end

      def get_client(request)
        client = persister.get("client:#{request.name}")
        if client
          MultiJson.load client
        else
          RPC::Response.new(nil, "404 Not Found", request.id)
        end
      end

      def generate_response(request)
        Zensu.logger.debug("handled api request: #{request}")
        if IMPLEMENTED_METHODS.include?(request.method.to_sym)
          response = send(request.method, request)
          response.is_a?(RPC::Response) ? response : RPC::Response.new(response, nil, request.id)
        else
          RPC::Response.new(nil, "404 Not Found", request.id)
        end
      end
    end
  end
end
