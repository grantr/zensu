module Zensu
  module Client

    def self.run(options={})
      Zensu.setup(options)
      App.run
    end

    def self.run!(options={})
      Zensu.setup(options)
      App.async.run
    end


    class App < Celluloid::SupervisionGroup
      supervise Subscriber
      supervise KeepalivePusher
      supervise Keyslave, args: [{:handshake => true}]
    end
  end
end
