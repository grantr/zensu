require 'openssl'
require 'base64'
require 'securerandom'

module Zensu
  module RPC
    module SSL
      def cacert
        @cacert ||= OpenSSL::X509::Certificate.new Zensu.settings.ssl.cacert
      end

      def certificate
        @certificate ||= OpenSSL::X509::Certificate.new Zensu.settings.ssl.certificate
      end

      def private_key
        @private_key ||= OpenSSL::PKey::RSA.new Zensu.settings.ssl.private_key
      end

      def valid_certificate?(cert)
        #TODO should request object take care of this? - assume we have a cert object here
        cert = cert.is_a?(String) ? OpenSSL::X509::Certificate.new(cert) : cert
        cert.verify(cacert.public_key)
      end

      def public_encrypt(cert, string)
        #TODO should request object take care of this? - assume we have a key object here
        cert = cert.is_a?(String) ? OpenSSL::X509::Certificate.new(cert) : cert
        Base64.strict_encode64(cert.public_key.public_encrypt(string))
      end

      def private_decrypt(key, string)
        key = key.is_a?(String) ? OpenSSL::PKey::RSA.new(key) : key
        key.private_decrypt(Base64.strict_decode64(string))
      end

      def generate_shared_key(length)
        # This is what Cipher#random_key uses (plus base64)
        Base64.strict_encode64 SecureRandom.random_bytes(length)
      end

      def generate_iv(length)
        # This is what Cipher#random_iv uses
        SecureRandom.random_bytes(length)
      end
      
      def cipher
        @cipher ||= OpenSSL::Cipher::Cipher.new(Zensu.settings.ssl.cipher)
      end

      def symmetric_encrypt(key, data)
        cipher.encrypt
        cipher.iv = iv = generate_iv(cipher.iv_len)
        cipher.key = key
        encrypted = cipher.update(data) + cipher.final
        # iv is public, so ok to send it plain
        encrypted.prepend(iv)
        Base64.strict_encode64(encrypted)
      end

      def symmetric_decrypt(key, string)
        cipher.decrypt
        cipher.key = key
        decoded_string = Base64.strict_decode64(string)
        iv, data = decoded_string[0..cipher.iv_len-1], decoded_string[cipher.iv_len..-1]
        cipher.iv = iv
        cipher.update(data) + cipher.final
      end
    end
  end
end
