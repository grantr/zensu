require 'spec_helper'

describe Zensu::Client::Subscriber do
  let(:broadcaster) { Zensu::Server::Broadcaster.new }

  before(:each) do
    # for checks and subscriptions
    Zensu.settings = Zensu::Settings.load(config_file('config.json'))
  end

  after(:each) do
    #subject.terminate
    #broadcaster.terminate
  end

  it 'should connect to all servers'

  it 'should create subscriptions'

  it 'should create pushers for each check'

  it 'should run pushers when a check is received'

  it 'should handle commands with the command pusher'

  it 'should subscribe to the system channel'

  it 'should subscribe to check channels'
end
