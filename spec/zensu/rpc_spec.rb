require 'spec_helper'

shared_context 'a Notification' do
  subject { described_class.new('method', {'foo' => 'bar'}) }

  it 'responds to method and params' do
    subject.method.should == 'method'
    subject.params.should == {'foo' => 'bar'}
  end

  it 'renders to json' do
    subject.as_json.should include('params' => { 'foo' => 'bar' })
    subject.as_json.should include('method' => 'method')
  end

  it 'skips params in json if they are missing' do
    subject = described_class.new('method')
    subject.as_json.should include('method' => 'method')
    subject.as_json.should_not include('params')
  end

  it 'includes the jsonrpc envelope' do
    subject.as_json.should include('jsonrpc' => '2.0')
  end

  it 'includes the version string' do
    subject.as_json.should include('v' => Zensu::RPC::VERSION_STRING)
  end

  it 'responds to param methods' do
    subject.foo.should == 'bar'
  end

  it 'raises on nonexistent param methods' do
    -> { subject.foo2 }.should raise_error(NoMethodError)
  end

  it 'parses a decoded json string' do
    subject = described_class.parse(MultiJson.load(%({"jsonrpc":"2.0","method":"method","params":{"foo":"bar"}})))
    subject.method.should == 'method'
    subject.params.should == {'foo' => 'bar'}
  end

end

describe Zensu::RPC::Notification do
  it_behaves_like "a Notification"
end

describe Zensu::RPC::Request do
  subject { described_class.new('method', {'foo' => 'bar'}) }

  it_behaves_like "a Notification"

  it 'should take an id parameter' do
    subject = described_class.new('method', {'foo' => 'bar'}, '1')
    subject.id.should == '1'
  end

  it 'should generate an id if not given' do
    subject.id.should_not be_empty
  end

  it 'should put the id in rendered json' do
    subject.as_json['id'].should == subject.id
  end

  it 'should parse the id' do
    subject = described_class.parse(MultiJson.load(%({"jsonrpc":"2.0","method":"method","params":{"foo":"bar"},"id":"1"})))
    subject.id.should == '1'
  end

end

describe Zensu::RPC::Response do
  subject { described_class.new({'foo' => 'bar'}, nil, '1') }

  it 'responds to result if success' do
    subject.result.should include('foo' => 'bar')
    subject.should be_success
  end

  it 'respond to error if error' do
    subject = described_class.new(nil, 'error')
    subject.error.should == 'error'
    subject.should be_error
  end

  it 'takes an id' do
    subject.id.should == '1'
  end

  it 'renders to json' do
    subject.as_json.should include('result' => { 'foo' => 'bar' })
    subject.as_json.should include('id' => '1')
  end

  it 'skips error in json if success' do
    subject.as_json.should_not include('error')
  end

  it 'skips result in json if error' do
    subject = described_class.new(nil, 'error')
    subject.as_json.should_not include('result')
  end

  it 'responds to result methods' do
    subject.foo.should == 'bar'
  end

  it 'raises on nonexistent result methods' do
    -> { subject.foo2 }.should raise_error(NoMethodError)
  end

  it 'includes the jsonrpc envelope' do
    subject.as_json.should include('jsonrpc' => '2.0')
  end

  it 'includes the version string' do
    subject.as_json.should include('v' => Zensu::RPC::VERSION_STRING)
  end

  it 'parses a success json string' do
    subject = described_class.parse(MultiJson.load(%({"jsonrpc":"2.0","result":{"foo":"bar"},"id":"1"})))
    subject.id.should == '1'
    subject.result.should include("foo" => "bar")
    subject.should be_success
  end

  it 'parses an error json string' do
    subject = described_class.parse(MultiJson.load(%({"jsonrpc":"2.0","error":"error","id":"1"})))
    subject.id.should == '1'
    subject.error.should == 'error'
    subject.should be_error
  end
end
