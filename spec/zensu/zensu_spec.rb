require 'spec_helper'

describe Zensu do
  it 'has settings by default' do
    Zensu.settings.should_not be_nil
    Zensu.settings.class.name.should == Zensu::Settings.name
  end

  # it 'sets settings' do
  #   Zensu.settings = nil
  #   Zensu.settings.should be_nil
  # end

  it 'has a logger by default' do
    Zensu.logger.should be_a Cabin::Channel
  end

  #TODO use metaprograming for this so logger/settings can be nil 
  # it 'sets the logger' do
  #   Zensu.logger = nil
  #   Zensu.logger.should be_nil
  # end
  
end
