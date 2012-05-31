require 'spec_helper'

describe Zensu::Server::Broadcaster do
  before(:each) do
    Zensu.settings = Zensu::Settings.load(config_file('config.json'))
  end

  it 'should bind to the broadcast port'

  it 'should add checks'

  it 'should broadcast to the proper subscribers'

  it 'should broadcast at the proper intervals'
end
