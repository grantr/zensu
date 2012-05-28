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
            #TODO add server health
          }
        }
      end

      def get_clients(request)
        [persister.smembers('clients').collect do |client|
          MultiJson.load persister.get("client:#{client}")
        end]
      end

      def get_client(request)
        client = persister.get("client:#{request.name}")
        if client
          MultiJson.load client
        else
          [nil, :not_found]
        end
      end

      def delete_client(request)
        #TODO
      end

      def get_checks(request)
        Zensu.settings.checks
      end

      def get_check(request)
        if Zensu.settings.checks.has_key?(request.name)
          Zensu.settings.checks[request.name]
        else
          [nil, :not_found]
        end
      end

      def post_check_request(request)
        #TODO
      end

      def get_events(request)
        [persister.smembers('clients').collect do |client|
          persister.hgetall("events:#{client}").collect do |check, event_json|
            MultiJson.load(event_json).merge('client' => client, 'check' => check)
          end
        end.flatten]
      end

      def get_event(request)
        events = persister.hgetall("events:#{request.client}")
        if events[request.check]
          events[request.check].merge('client' => request.client, 'check' => request.check)
        else
          [nil, :not_found]
        end
      end

      def post_event_resolve(request)
        #TODO
      end

      def post_stash(request)
        if request.path.empty?
          return [nil, :bad_request]
        end

        begin
          body = MultiJson.load(request.body)
          #TODO pipeline
          persister.set("stash:#{request.path}", MultiJson.dump(body))
          persister.sadd("stashes", request.path)
          { "status" => :created }
        rescue MultiJson::DecodeError
          [nil, :bad_request]
        end
      end

      def get_stash(request)
        body = persister.get("stash:#{request.path}")
        if body
          MultiJson.load(body)
        else
          [nil, :not_found]
        end
      end

      def delete_stash(request)
        if persister.exists("stash:#{request.path}")
          #TODO pipeline
          persister.srem("stashes", request.path)
          persister.del("stash:#{request.path}")
          { "status" => :no_content }
        else
          [nil, :not_found]
        end
      end

      def get_stashes(request)
        [persister.smembers("stashes")]
      end

      def post_stashes(request)
        #TODO
      end

      def generate_response(request)
        Zensu.logger.debug("handled api request: #{request}")
        if IMPLEMENTED_METHODS.include?(request.method.to_sym)
          result, error = send(request.method, request)
          RPC::Response.new(result, error, request.id)
        else
          RPC::Response.new(nil, :not_found, request.id)
        end
      end
    end
  end
end
