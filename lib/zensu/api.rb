require 'reel'

module Zensu
  module API

    def self.run
      Zensu.setup
      Group.run
    end

    def self.run!
      Zensu.setup
      Group.run!
    end

    class Group < Celluloid::Group
      supervise App
    end
  end
end
