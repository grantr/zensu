require 'openssl'
module Zensu
  module RPC
    module Encoding
      include RPC::SSL

      def encode(message)
        encoded_message = message.respond_to?(:as_json) ? message.as_json : message
        if authenticated?
          encrypt_message MultiJson.dump(encoded_message)
        else
          MultiJson.dump message
        end
      end

      def decode(message)
        if encrypted?(message)
          MultiJson.load decrypt_message(message)
        else
          MultiJson.load message
        end
      end

      def encrypted_envelope
        { 'v' => 1, 'cipher' => Zensu.settings.ssl.cipher }
      end

      def encrypt_message(message)
        payload = symmetric_encrypt Zensu.settings.ssl.shared_key, message
        # This v is NOT using semantic versioning since this is a container format
        # rather than an api.
        MultiJson.dump encrypted_envelope.tap do |e|
          e['payload'] = payload
        end
      end

      def decrypt_message(message)
        symmetric_decrypt Zensu.settings.ssl.shared_key, MultiJson.load(message)['payload']
      end

      #TODO This causes an unnecessary json parse for all messages
      def encrypted?(message)
        MultiJson.load(message).has_key?('cipher')
      end

      def authenticated?
        !Zensu.settings.ssl.shared_key.nil?
      end
    end

  end
end
