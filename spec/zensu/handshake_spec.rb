require 'spec_helper'

describe Zensu::RPC::Handshake::Keymaster do
  before(:each) do
    # for ssl certs
    Zensu.settings = Zensu::Settings.load(config_file('config.json'))
  end

  it 'should return a successful response given a valid cert' do
    request = Zensu::RPC::Request.new('handshake', {'name' => 'test', 'cert' => Zensu.settings.ssl.certificate})
    response = subject.respond(request)
    response.should be_success
    response.result['cert'].should == Zensu.settings.ssl.certificate
    response.result['cipher'].should == Zensu.settings.ssl.cipher
    response.result['shared_key'].should_not be_nil
  end

  it 'should encrypt the shared key with the client cert' do
    request = Zensu::RPC::Request.new('handshake', {'name' => 'test', 'cert' => Zensu.settings.ssl.certificate})
    response = subject.respond(request)
    subject.private_decrypt(subject.private_key, response.result['shared_key']).should == subject.shared_key
  end

  it 'should set the global shared key' do
    request = Zensu::RPC::Request.new('handshake', {'name' => 'test', 'cert' => Zensu.settings.ssl.certificate})
    response = subject.respond(request)
    Zensu.settings.ssl.shared_key.should == subject.shared_key
  end

  it 'should return an error if cert was invalid' do
    request = Zensu::RPC::Request.new('handshake', {'name' => 'test', 'cert' => File.read(config_file('invalid_cert.pem'))})
    response = subject.respond(request)
    response.should be_error
  end

end

describe Zensu::RPC::Handshake::Keyslave do

  after(:each) do
    subject.terminate
  end

  it 'should generate handshake requests' do
    request = subject.generate_request
    request.method.should == 'handshake'
    request.name.should == Zensu.settings.client.name
    request.cert.should == Zensu.settings.ssl.certificate
  end

  it 'should clear shared key if server cert is invalid' do
    response = Zensu::RPC::Response.new('cert' => File.read(config_file('invalid_cert.pem')))
    subject.handle_response(response)
    Zensu.settings.ssl.shared_key.should be_nil
  end

  it 'should decrypt the returned shared key' do
    response = Zensu::RPC::Response.new('cert' => Zensu.settings.ssl.certificate, 'shared_key' => subject.public_encrypt(Zensu.settings.ssl.certificate, '1'), 'cipher' => Zensu.settings.ssl.cipher)
    subject.handle_response(response)
    subject.shared_key.should == '1'
  end

  it 'should set the global shared key and cipher' do
    response = Zensu::RPC::Response.new('cert' => Zensu.settings.ssl.certificate, 'shared_key' => subject.public_encrypt(Zensu.settings.ssl.certificate, '1'), 'cipher' => 'cipher')
    subject.handle_response(response)
    Zensu.settings.ssl.shared_key.should == '1'
    Zensu.settings.ssl.cipher.should == 'cipher'
  end
end
