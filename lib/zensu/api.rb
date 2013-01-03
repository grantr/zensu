require 'reel'

module Zensu
  module API

    def self.run(options={})
      Zensu.setup(options)
      App.run
    end

    def self.run!(options={})
      Zensu.setup(options)
      App.async.run
    end

    class App < Celluloid::SupervisionGroup
      supervise Client::Keyslave, args: [{:handshake => true}]
      supervise Handler
    end
  end
end
