require 'openssl'
require 'base64'

module Zensu
  module SSL
    def ca_certificate
      @ca_certificate ||= OpenSSL::X509::Certificate.new Zensu.settings.ssl.cacert
    end

    def certificate
      @certificate ||= OpenSSL::X509::Certificate.new Zensu.settings.ssl.cert
    end

    def private_key
      @private_key ||= OpenSSL::PKey::RSA.new Zensu.settings.ssl.key
    end

    def valid_certificate?(cert)
      #TODO should request object take care of this? - assume we have a cert object here
      cert = cert.is_a?(String) ? OpenSSL::X509::Certificate.new(cert) : cert
      cert.verify(ca_certificate.public_key)
    end
    
    def public_encrypt(cert, string)
      #TODO should request object take care of this? - assume we have a key object here
      cert = cert.is_a?(String) ? OpenSSL::X509::Certificate.new(cert) : cert
      Base64.urlsafe_encode64(cert.public_key.public_encrypt(string))
    end

    def private_decrypt(key, string)
      key = key.is_a?(String) ? OpenSSL::PKey::RSA.new(key) : key
      key.private_decrypt(Base64.urlsafe_decode64(string))
    end

  end
end
