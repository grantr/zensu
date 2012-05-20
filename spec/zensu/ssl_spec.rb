require 'spec_helper'

describe Zensu::RPC::SSL do
  let(:described_class) { Class.new { include Zensu::RPC::SSL } }
  subject { described_class.new }

  before(:each) do
    # for ssl certs
    Zensu.settings = Zensu::Settings.load(config_file('config.json'))
  end

  it 'creates ssl objects' do
    subject.cacert.should be_a(OpenSSL::X509::Certificate)
    subject.certificate.should be_a(OpenSSL::X509::Certificate)
    subject.private_key.should be_a(OpenSSL::PKey::RSA)
  end

  it 'validates certificates' do
    subject.valid_certificate?(subject.certificate).should be_true
  end

  it 'invalidates invalid certificates' do
    invalid_cert = OpenSSL::X509::Certificate.new(File.read(config_file('invalid_cert.pem')))
    subject.valid_certificate?(invalid_cert).should be_false
  end

  it 'encrypts and decrypts strings with public keys' do
    data = subject.public_encrypt(subject.certificate, "omg public key encryption")
    subject.private_decrypt(subject.private_key, data).should == "omg public key encryption"
  end

  it 'encodes public key encrypted data with base64' do
    subject.public_encrypt(subject.certificate, "omg public key encryption").should be_base64
  end

  it 'generates base64-encoded random shared keys' do
    subject.generate_shared_key(32).bytesize.should be >= 32
    subject.generate_shared_key(32).should be_base64
  end

  it 'should generate random initialization vectors with specific length' do
    subject.generate_iv(16).bytesize.should == 16
  end

  it 'should encrypt and decrypt strings' do
    key = SecureRandom.random_bytes(32)
    data = subject.symmetric_encrypt(key, "omg symmetric encryption")
    subject.symmetric_decrypt(key, data).should == "omg symmetric encryption"
  end

  it 'should encode symmetric encrypted data with base64' do
    key = SecureRandom.random_bytes(32)
    data = subject.symmetric_encrypt(key, "omg symmetric encryption").should be_base64
  end

end
