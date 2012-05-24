module Zensu
  module Server
    class Keymaster < RPC::Responder
      include RPC::SSL
      include Persistence

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
        persister.setnx(shared_key_key, generate_shared_key(cipher.key_len))
        @shared_key = persister.get(shared_key_key)
        Zensu.settings.ssl.shared_key = @shared_key
      end

      def shared_key_key
        "keymaster:shared_key"
      end
    end
  end
end
