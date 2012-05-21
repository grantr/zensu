module Zensu
  module RPC
    module Handshake

      class Keymaster < Responder
        include SSL

        #TODO add loop to check for updated key

        def handle(request)
          if valid_certificate?(request.cert)
            result = { 
              'cert' => Zensu.settings.ssl.certificate, 
              'cipher' => Zensu.settings.ssl.cipher,
              'shared_key' => public_encrypt(request.cert, shared_key) }
            Response.new(result, nil, request.id)
          else
            Response.new(nil, "Invalid certificate", request.id)
          end
        end

        def shared_key
          @shared_key ||= generate_shared_key(cipher.key_len) #TODO get/set the shared key in redis
          Zensu.settings.ssl.shared_key = @shared_key
        end
      end

      class Keyslave < Requester
        include SSL

        #TODO make this a state machine that transitions when key becomes valid/invalid
        #TODO there should be an actor that manages authentication. all rpc actors are supervised by this class and restarted when it detects that handshake needs to happen again

        def request
          Request.new("handshake", {'name' => Zensu.settings.client.name, 'cert' => Zensu.settings.ssl.certificate})
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
end
