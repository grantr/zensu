module Zensu
  module RPC
    module Handshake

      class Keymaster < Responder
        include SSL

        #TODO add loop to check for updated key

        def handle(request)
          if valid_certificate?(request.cert)
            result = { 'cert' => certificate.to_pem, 'shared_key' => public_encrypt(request.cert, shared_key) }
            Response.new(result, nil, request.id)
          else
            #TODO errors
            Response.new("", "error", request.id)
          end
        end

        def shared_key
          "bacon" #TODO get the shared key from redis
        end

      end

      class Keyslave < Requester
        include SSL

        #TODO make this a state machine that transitions when key becomes valid/invalid

        def request
          Request.new("handshake", {name: Zensu.settings.client.name, cert: certificate.to_pem})
        end

        def handle_response(response)
          #TODO retry if handshake failed
          if valid_certificate?(response.cert)
            @shared_key = private_decrypt(private_key, response.shared_key)
          else
            @shared_key = nil
          end
        end

        def authenticated?
          !@shared_key.nil?
        end

        def shared_key
          @shared_key
        end

      end
    end
  end
end
