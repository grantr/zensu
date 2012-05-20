require 'rubygems'
require 'bundler/setup'
require 'zensu'

# Squelch the logger (comment out this line if you want it on for debugging)
#Zensu.logger = nil

Dir['./spec/support/*.rb'].map {|f| require f }

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
