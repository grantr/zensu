module Zensu
  module Client

    def self.run(options={})
      Zensu.setup(options)
      Group.run
    end

    def self.run!(options={})
      Zensu.setup(options)
      Group.run!
    end


    class Group < Celluloid::Group
      supervise Subscriber
      supervise KeepalivePusher
      supervise Keyslave, args: [{:handshake => true}]
    end
  end
end
