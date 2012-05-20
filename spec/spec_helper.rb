require 'bundler/setup'

if ENV['COVERAGE'] == 'true' && (RUBY_ENGINE == "ruby")
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'zensu'

Dir['./spec/support/*.rb'].map {|f| require f }

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
