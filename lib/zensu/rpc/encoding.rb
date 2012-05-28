require 'openssl'
module Zensu
  module RPC
    module Encoding
      include RPC::SSL

      VERSION_STRING = '1'


      def encode(message)
        message = message.respond_to?(:as_json) ? message.as_json : message
        if encrypt_message?(message)
          data = encrypt_message MultiJson.dump(message)
        else
          data = MultiJson.dump message
        end
        Zensu.logger.debug "sending: #{data}"
        data
      end

      def decode(message)
        Zensu.logger.debug "received: #{message}"
        if encrypted?(message)
          #TODO raise if cannot decrypt
          MultiJson.load decrypt_message(message)
        else
          #TODO raise if message is supposed to be encrypted
          MultiJson.load message
        end
      end

      def encrypted_envelope
        { 'v' => VERSION_STRING, 'cipher' => Zensu.settings.ssl.cipher }
      end

      def encrypt_message(message)
        # This v is NOT using semantic versioning since this is a container format
        # rather than an api.
        MultiJson.dump(encrypted_envelope.tap do |e|
          e['payload'] = symmetric_encrypt Zensu.settings.ssl.shared_key, message
        end)
      end

      def decrypt_message(message)
        symmetric_decrypt Zensu.settings.ssl.shared_key, MultiJson.load(message)['payload']
      end

      #TODO This causes an unnecessary json parse for all messages
      def encrypted?(message)
        MultiJson.load(message).has_key?('cipher')
      end

      def encrypt_message?(message)
        # HACK figure out a way for messages to say whether they should be transmitted in plaintext
        !Zensu.settings.ssl.shared_key.nil? && 
          !((message['result'] && message['result'].respond_to?(:has_key?) && message['result'].has_key?('cert')) || (message['params'] && message['params'].respond_to?(:has_key?) && message['params'].has_key?('cert')))
      end
    end

  end
end
