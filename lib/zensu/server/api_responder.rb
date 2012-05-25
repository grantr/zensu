module Zensu
  module Server
    class APIResponder < Responder
      include Persistence

      # the http api should use this rpc channel instead of talking to redis directly.
      # possible methods handled:
      # api:
      #   get   /info
      #   get   /clients
      #   get   /client/:name
      #   del   /client/:name
      #   get   /checks
      #   get   /check/:name
      #   post  /check/request
      #   get   /events
      #   get   /event/:client/:check
      #   post  /event/resolve
      #   post  /stash/*
      #   get   /stash/*
      #   del   /stash/*
      #   get   /stashes
      #   post  /stashes
      #


      # method: "get"
      # {
      #   path: "/events"
      #   headers: {}
      #   body: ""
      # } 
      #
      # It will be impossible to support streaming responses like this. maybe api needs to be something different
      # might make sense to add an http router?
      # maybe this should really be a spdy socket?
      #
      # the current sensu api does not support streaming: the dashboard implements websockets on its own
      
      def generate_response(request)
        Zensu.logging.debug("handled api request: #{request}")
        RPC::Response.new("", nil, request.id)
      end
    end
  end
end
