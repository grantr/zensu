module Zensu
  module RPC
    module Handshake

      class Keymaster < Responder
        include SSL

        #TODO add loop to check for updated key

        def handle(request)
          if valid_certificate?(request.cert)
            result = { 
              'cert' => certificate.to_pem, 
              'cipher' => Zensu.settings.ssl.cipher,
              'shared_key' => public_encrypt(request.cert, shared_key) }
            Response.new(result, nil, request.id)
          else
            #TODO errors
            Response.new("", "error", request.id)
          end
        end

        def shared_key
          @shared_key ||= generate_shared_key(cipher.key_len) #TODO get/set the shared key in redis
        end
      end

      class Keyslave < Requester
        include SSL

        #TODO make this a state machine that transitions when key becomes valid/invalid
        #TODO there should be an actor that manages authentication. all rpc actors are supervised by this class and restarted when it detects that handshake needs to happen again

        def request
          Request.new("handshake", {name: Zensu.settings.client.name, cert: certificate.to_pem})
        end

        def handle_response(response)
          #TODO retry if handshake failed
          if valid_certificate?(response.cert)
            Zensu.settings.ssl.shared_key = private_decrypt(private_key, response.shared_key)
            Zensu.settings.ssl.cipher = response.cipher
          else
            Zensu.settings.ssl.shared_key = nil
          end
          #TODO state transition
        end
      end
    end
  end
end
