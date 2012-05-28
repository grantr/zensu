require 'spec_helper'

describe Zensu::RPC::Requester do
  let(:requester_class) do
    Class.new(Zensu::RPC::Requester) do
      def generate_request
        Zensu::RPC::Request.new("test")
      end

      def handle_response(request)
        "success"
      end
    end
  end

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

  after(:each) do
    subject.terminate
  end

  #TODO how to test this?
  # it 'should time out' do
  #   requester = requester_class.new(timeout: 1)
  #   -> { requester.request; requester.sleep 1 }.should raise_error(Celluloid::Task::TerminatedError)
  # end


  it 'should return the response' do
    rr = Zensu::Server::ResponseRouter.new
    rr.handle :test, with: responder_class
    requester = requester_class.new
    response = requester.request
    response.should == 'success'
    requester.terminate
  end

end
