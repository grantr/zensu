require 'spec_helper'

describe Zensu::Client::Keyslave do

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
