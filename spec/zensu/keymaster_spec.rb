require 'spec_helper'

describe Zensu::Server::Keymaster do
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
