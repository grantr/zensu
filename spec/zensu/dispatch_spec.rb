require 'spec_helper'

describe Zensu::RPC::Dispatch do
  let(:described_class) {
    Class.new do
      include Zensu::RPC::Dispatch
    end
  }

  subject { described_class.new }

  let(:handler_class) {
    Class.new do
      include Celluloid

      def handle
        abort("uh oh")
      end
    end
  }

  after(:each) do
    subject.handlers.values.each { |h| h.terminate if h.alive? }
  end
  
  it 'should add handlers' do
    subject.handle :test, with: handler_class
    subject.handler_for(:test).should be_a(handler_class)
  end

  it 'should add handlers that are actors' do
    subject.handle :test, with: handler_class.new
    subject.handler_for(:test).should be_a(handler_class)
  end

  it 'should dispatch multiple methods to one handler' do
    subject.handle [:test, :test2], with: handler_class
    h1 = subject.handler_for(:test)
    h2 = subject.handler_for(:test2)
    h1.should be_a(handler_class)
    h2.should == h1
  end

  it 'should supervise newly created handlers' do
    subject.handle :test, with: handler_class
    subject.handler_for(:test).should be_alive
    -> { subject.handler_for(:test).handle }.should raise_error
    subject.handler_for(:test).should be_alive
  end
end
