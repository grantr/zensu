require 'thor'

module Zensu
  class CLI < Thor
    desc "example", "an example task"
    def example
      puts "I'm a thor task!"
    end
  end
end
