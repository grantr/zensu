require 'spec_helper'

describe Zensu::RPC::Encoding do
  let(:described_class) { Class.new { include Zensu::RPC::Encoding } }
  subject { described_class.new }

  before(:each) do
    # for ssl certs
    Zensu.settings = Zensu::Settings.load(config_file('config.json'))
    Zensu.settings.ssl.shared_key = subject.generate_shared_key(32)
  end
  
  it 'encodes and decodes plain-text messages' do
    encoded = subject.encode('foo' => 'bar')
    subject.decode(encoded).should include('foo' => 'bar')
  end

  it 'encodes messages with as_json if possible' do
    message_class = Struct.new(:method) do
      def as_json
        { "method" => method }
      end
    end
    encoded = subject.encode(message_class.new('method'))
    subject.decode(encoded).should include('method' => 'method')
  end

  it 'encrypts messages with an envelope' do
    Zensu.settings.ssl.shared_key = SecureRandom.random_bytes(32)
    envelope = MultiJson.load subject.encode('foo' => 'bar')

    envelope['cipher'].should == 'AES-256-CBC'
    envelope['v'].should == Zensu::RPC::Encoding::VERSION_STRING
    envelope['payload'].should_not be_nil
  end

  it 'encodes and decodes encrypted messages' do
    Zensu.settings.ssl.shared_key = SecureRandom.random_bytes(32)
    encoded = subject.encode('foo' => 'bar')
    subject.decode(encoded).should include('foo' => 'bar')
  end

end
