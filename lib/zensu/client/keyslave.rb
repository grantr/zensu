module Zensu
  module Client
    class Keyslave < RPC::Requester
      include RPC::SSL

      #TODO make this a state machine that transitions when key becomes valid/invalid
      #TODO there should be an actor that manages authentication. all rpc actors are supervised by this class and restarted when it detects that handshake needs to happen again

      # TODO this causes specs to hang
      def initialize(options={})
        super()

        async.request if options[:handshake]
      end

      def generate_request
        RPC::Request.new("handshake", {'name' => Zensu.settings.client.name, 'cert' => Zensu.settings.ssl.certificate}).tap do |r|
          r.plaintext = true
        end
      end

      def handle_response(response)
        #TODO retry if handshake failed
        if valid_certificate?(response.cert)
          @shared_key = private_decrypt(private_key, response.shared_key)
          Zensu.settings.ssl.shared_key = @shared_key
          Zensu.settings.ssl.cipher = response.cipher
        else
          Zensu.settings.ssl.shared_key = nil
        end
        #TODO state transition
      end

      def shared_key
        @shared_key
      end
    end
  end
end
