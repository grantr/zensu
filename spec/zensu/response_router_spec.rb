require 'spec_helper'

describe Zensu::Server::ResponseRouter do
  let(:requester) { Zensu::RPC::Requester.new }

  before(:each) do
    Zensu.settings = Zensu::Settings.load(config_file('config.json'))
    Zensu.settings.ssl.encryption = false
  end

  after(:each) do
    subject.terminate
  end

  it 'should bind to the rpc port' do
    #socket = Celluloid::ZMQ::RepSocket.new
    #-> { socket.bind("tcp://127.0.0.1:5567") }.should raise_error(IOError)
    #socket.close
  end

  it 'should handle handshakes with the keymaster' do
    subject.handler_for(:handshake).should be_a(Zensu::Server::Keymaster)
  end

  it 'should handle api requests with the api responder' do
    Zensu::Server::APIResponder::IMPLEMENTED_METHODS.each do |method|
      @handler ||= subject.handler_for(method)
      subject.handler_for(method).should be_a(Zensu::Server::APIResponder)
      subject.handler_for(method).should == @handler
    end
  end

  it 'should respond to unknown methods with method_not_allowed' do
    subject.should be_a(Zensu::Server::ResponseRouter)
    response = requester.request("unknown_method")
    response.should be_a(Zensu::RPC::Response)
    response.should be_error
    response.error.should == "method_not_allowed"
  end
end
