module Zensu
  module Server
    class Elector
      include Celluloid

      #TODO dcell would make sense for servers, since they are essentially a p2p network and could use things like gossip, leader election, and consensus.
      #
      # without dcell, servers need:
      # a pubsub network among themselves
      # leader election
      # redis failover
      # possibly ring partitioning
    end
  end
end
