# -*- encoding: utf-8 -*-
require File.expand_path('../lib/zensu/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Grant Rodgers"]
  gem.email         = ["grantr@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = "https://github.com/grantr/zensu"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "zensu"
  gem.require_paths = ["lib"]
  gem.version       = Zensu::VERSION
  gem.platform      = Gem::Platform::RUBY

  gem.add_runtime_dependency "celluloid"
  gem.add_runtime_dependency "celluloid-zmq"
  gem.add_runtime_dependency "multi_json"
  gem.add_runtime_dependency "redis"
  gem.add_runtime_dependency "redis-namespace"
end
