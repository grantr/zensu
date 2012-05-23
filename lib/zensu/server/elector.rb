module Zensu
  module Server
    class Elector
      include Celluloid

      include Persistence

      #TODO dcell would make sense for servers, since they are essentially a p2p network and could use things like gossip, leader election, and consensus.
      #
      # without dcell, servers need:
      # a pubsub network among themselves
      # leader election
      # redis failover
      # possibly ring partitioning
      
      def initialize
        @is_leader = false
        run!
      end

      def finalize
        demote if is_leader?
      end

      def is_leader?
        @is_leader
      end

      # this is the leader election logic from sensu

      def run
        if is_leader?
          persister.set(leader_lock_key, Time.now.to_i)
        else
          request_leader_election
        end
        after(20) { run }
      end

      def request_leader_election
        if persister.setnx(leader_lock_key, Time.now.to_i)
          promote!
        else
          timestamp = persister.get(leader_lock_key)
          if Time.now.to_i - timestamp.to_i >= 60
            previous = persister.getset(leader_lock_key, Time.now.to_i)
            if previous == timestamp
              promote!
            end
          end

        end
      end

      def promote
        @is_leader = true
        start_leader_duties
        Zensu.logger.info("I am now the leader")
      end

      def demote
        if is_leader?
          @is_leader = false
          stop_leader_duties
          # could this delete be dangerous in a net split scenario?
          persister.del(leader_lock_key) if persister.alive? #TODO this doesn't work because actors are not terminated in the proper order
          Zensu.logger.info("I am no longer the leader")
        else
          Zensu.logger.warn("Not currently the leader")
        end
      end

      def start_leader_duties
        @broadcaster = Broadcaster.supervise
      end

      def stop_leader_duties
        @broadcaster.terminate if @broadcaster.alive?
      end


      def leader_lock_key
        "lock:leader"
      end
    end
  end
end
