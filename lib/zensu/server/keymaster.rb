module Zensu
  module Server
    class Keymaster < RPC::Responder
      include RPC::SSL

      #TODO add loop to check for updated key

      def generate_response(request)
        if valid_certificate?(request.cert)
          result = { 
            'cert' => Zensu.settings.ssl.certificate, 
            'cipher' => Zensu.settings.ssl.cipher,
            'shared_key' => public_encrypt(request.cert, shared_key) }
            RPC::Response.new(result, nil, request.id)
        else
          RPC::Response.new(nil, "Invalid certificate", request.id)
        end
      end

      def shared_key
        @shared_key ||= generate_shared_key(cipher.key_len) #TODO get/set the shared key in redis
        Zensu.settings.ssl.shared_key = @shared_key
      end
    end
  end
end
