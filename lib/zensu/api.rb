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
      supervise Client::Keyslave, args: [{:handshake => true}]
      supervise App
    end
  end
end
