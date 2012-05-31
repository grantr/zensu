require 'spec_helper'

describe Zensu::RPC::Requester do
  let(:responder_class) do
    Class.new(Zensu::RPC::Responder) do
      def respond(request)
        Zensu::RPC::Response.new("success", nil, request.id)
      end
    end
  end

  before(:each) do
    # for ips
    Zensu.settings = Zensu::Settings.load(config_file('config.json'))
    Zensu.settings.ssl.shared_key = subject.generate_shared_key(32)
  end

  #TODO how to test this?
  it 'should time out' do
    quick_requester = described_class.new(timeout: 0.1)
    response = quick_requester.request('test')
    response.should be_a(Zensu::RPC::Response)
    response.should be_error
    response.error.should == "gateway_timeout"
    quick_requester.terminate
  end


  it 'should return the response' do
    rr = Zensu::Server::ResponseRouter.new
    rr.handle :test, with: responder_class
    response = subject.request('test')
    response.should be_a(Zensu::RPC::Response)
    response.should be_success
    response.result.should == 'success'
    rr.terminate
  end

end
