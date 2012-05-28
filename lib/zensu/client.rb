module Zensu
  module Client

    def self.run
      Zensu.setup
      Group.run
    end

    def self.run!
      Zensu.setup
      Group.run!
    end


    class Group < Celluloid::Group
      supervise Pubsub::Broker
      supervise Subscriber
      supervise KeepalivePusher
      supervise Keyslave, args: [{:handshake => true}]
    end
  end
end
