require 'reel'

module Zensu
  module API

    def self.run(options={})
      Zensu.setup(options)
      Group.run
    end

    def self.run!(options={})
      Zensu.setup(options)
      Group.run!
    end

    class Group < Celluloid::Group
      supervise Client::Keyslave, args: [{:handshake => true}]
      supervise App
    end
  end
end
