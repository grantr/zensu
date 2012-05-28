module Zensu
  module Server
    class CheckResultHandler
      include Celluloid

      include Persistence

      def handle(message)
        Zensu.logger.debug("handling check result: #{message}")

        client = get_client(message.client['name'])

        if client
          #TODO merge check settings
          check = message.check
          #TODO pipeline
          persister.sadd("history:#{client['name']}", check['name']) # add the check to the client history set
          persister.rpush("history:#{client['name']}:#{check['name']}", check['status'])
          
          #TODO implement status logic and handle logic as filter chain

        else
          #TODO pipeline
          # this should just add the client - anything that can get to this point is a valid client
          persister.set "client:#{message.client['name']}", MultiJson.dump(message.client)
          persister.sadd("clients", client)
          Zensu.logger.warn("got check result from unknown client #{message.client['name']}")
        end

        # check for client key
        # if client doesn't exist, do nothing (log warning)
        # if client does exist
        #   parse client json
        #
        #   merge configured check settings with check as returned by client
        #   
        #   event is:
        #     client
        #     check
        #     occurrences = 1
        #
        #   add check name to client history set
        #   push check status to client history list of this check
        #   trim check status history to 20 elements and calculate state change
        #   
        #   get events for this client and check
        #   determine if check is flapping
        #
        #   if check failed (status != 0)
        #     set the event for client and check
        #     handle event TODO
        #   elsif previous occurrence
        #     mark check resolved
        #     handle resolve event
        #   elsif type == metric
        #     handle event
        #
        #
        #
        # handle_event:
        #   run the handler for the event

      end

      def get_client(name)
        client_json = persister.get("client:#{name}")
        client_json ? MultiJson.load(client_json) : nil
      end
    end
  end
end
