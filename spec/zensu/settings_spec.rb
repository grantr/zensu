require 'spec_helper'

describe Zensu::Settings do
  it 'has default values' do
    subject.checks.should == {}
    subject.handlers.should == {}
    subject.ssl.cipher.should == 'AES-256-CBC'
  end

  it 'parses json' do
    subject = Zensu::Settings.parse(File.read(config_file('config.json')))
    subject.redis.host.should == 'localhost'
  end

  it 'loads json files' do
    subject = Zensu::Settings.load(config_file('config.json'))
    subject.redis.host.should  == 'localhost'
  end

  it 'loads ssl files' do
    subject = Zensu::Settings.load(config_file('config.json'))
    subject.ssl.certificate.should == File.read(config_file('cert.pem'))
    subject.ssl.cacert.should == File.read(config_file('cacert.pem'))
    subject.ssl.private_key.should == File.read(config_file('key.pem'))
  end

  it 'loads ssl from config strings' do
    subject = Zensu::Settings.load(config_file('config_with_ssl.json'))
    subject.ssl.certificate.should == File.read(config_file('cert.pem'))
    subject.ssl.cacert.should == File.read(config_file('cacert.pem'))
    subject.ssl.private_key.should == File.read(config_file('key.pem'))
  end

end
