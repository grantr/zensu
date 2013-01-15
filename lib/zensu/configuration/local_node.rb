require 'red25519'
module Zensu
  class Configuration
    class LocalNode < Configuration

      def signing_key=(key)
        if key.is_a?(Ed25519::SigningKey)
          set(:signing_key, key.to_hex)
        else
          set(:signing_key, key)
        end
        # also set id
        set(:id, Ed25519::SigningKey.new(signing_key).verify_key.to_hex)
      end
    end
  end
end
