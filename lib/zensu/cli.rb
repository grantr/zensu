require 'thor'
require 'securerandom'

module Zensu
  class CLI < Thor
    desc "root_ca", "Generate a Root CA"
    method_option :name, type: :string, desc: "Common name"
    method_option :key_file,  type: :string, desc: "Key output file",  default: "cakey.pem"
    method_option :cert_file, type: :string, desc: "Cert output file", default: "cacert.pem"
    def root_ca
      name = options[:name] || get_option(:name, "common name")
      say "generating a root ca with name #{name}"
      #TODO config location of ssl certs

      root_key = OpenSSL::PKey::RSA.new 2048 # the CA's public/private key
      root_ca = OpenSSL::X509::Certificate.new
      root_ca.version = 2 # cf. RFC 5280 - to make it a "v3" certificate
      root_ca.serial = SecureRandom.random_number(100)
      root_ca.subject = OpenSSL::X509::Name.parse "/DC=com/DC=example/CN=#{name}" #TODO config cert subject
      root_ca.issuer = root_ca.subject # root CA's are "self-signed"
      root_ca.public_key = root_key.public_key
      root_ca.not_before = Time.now
      root_ca.not_after = root_ca.not_before + 2 * 365 * 24 * 60 * 60 # 2 years validity
      ef = OpenSSL::X509::ExtensionFactory.new
      ef.subject_certificate = root_ca
      ef.issuer_certificate = root_ca
      root_ca.add_extension(ef.create_extension("basicConstraints","CA:TRUE",true))
      root_ca.add_extension(ef.create_extension("keyUsage","keyCertSign, cRLSign", true))
      root_ca.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
      root_ca.add_extension(ef.create_extension("authorityKeyIdentifier","keyid:always",false))
      root_ca.sign(root_key, OpenSSL::Digest::SHA256.new)
      File.open(options[:key_file], "w") { |f| f.write(root_key.to_pem) }
      File.open(options[:cert_file], "w") { |f| f.write(root_ca.to_pem) }
    end

    desc "root_ca", "Generate a certificate"
    method_option :name,      type: :string, desc: "Common name"
    method_option :ca_key,    type: :string, desc: "Root CA private key (PEM format)",      default: "cakey.pem"
    method_option :ca_cert,   type: :string, desc: "Root CA certificate file (PEM format)", default: "cacert.pem"
    method_option :key_file,  type: :string, desc: "Key output file"
    method_option :cert_file, type: :string, desc: "Cert output file"
    def cert
      name = options[:name] || get_option(:name, "common name")
      say "generating a certificate with name #{name}"
      #TODO config location of ssl certs
      #TODO name should default to configured name
      key_file = options[:key_file] || "#{name}-key.pem"
      cert_file = options[:cert_file] || "#{name}-cert.pem"

      root_ca = OpenSSL::X509::Certificate.new(File.read(options[:ca_cert]))
      root_key = OpenSSL::PKey::RSA.new(File.read(options[:ca_key]))
      key = OpenSSL::PKey::RSA.new 2048
      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = SecureRandom.random_number(100)
      cert.subject = OpenSSL::X509::Name.parse "/DC=com/DC=example/CN=#{name}"
      cert.issuer = root_ca.subject # root CA is the issuer
      cert.public_key = key.public_key
      cert.not_before = Time.now
      cert.not_after = cert.not_before + 1 * 365 * 24 * 60 * 60 # 1 years validity
      ef = OpenSSL::X509::ExtensionFactory.new
      ef.subject_certificate = cert
      ef.issuer_certificate = root_ca
      cert.add_extension(ef.create_extension("keyUsage","digitalSignature", true))
      cert.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
      cert.sign(root_key, OpenSSL::Digest::SHA256.new)
      File.open(key_file, "w") { |f| f.write(key.to_pem) }
      File.open(cert_file, "w") { |f| f.write(cert.to_pem) }
    end

    desc "verify_cert", "Verify a certificate with the root CA"
    method_option :ca_cert,   type: :string, desc: "Root CA certificate file (PEM format)", default: "cacert.pem"
    method_option :cert_file, type: :string, desc: "Cert file"
    def verify_cert
      cert_file = options[:cert_file] || get_option(:cert_file, "Cert file")

      root_ca = OpenSSL::X509::Certificate.new(File.read(options[:ca_cert]))
      cert = OpenSSL::X509::Certificate.new(File.read(cert_file))

      if cert.verify(root_ca.public_key)
        say "Certificate is VALID."
      else
        say "Certificate is INVALID."
      end
    end

    protected
    def get_option(option, display_name=nil)
      value = ask("Please enter your #{display_name || option}:")
      raise Thor::Error, "You must enter a value for that field." if value.empty?
      value
    end
  end
end
