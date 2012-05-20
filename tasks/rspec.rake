require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

RSpec::Core::RakeTask.new(:coverage) do |task|
  ENV['COVERAGE'] = 'true'
end
