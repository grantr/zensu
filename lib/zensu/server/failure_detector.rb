require 'securerandom'

module Zensu
  module Server

    # Inspired by cassandra's phi accrual failure detector

    # TODO if redis fails, this class will hang. need a solution for that.
    #
    # servers could receive keepalives from the pull socket. if they are not the leader they
    # rebroadcast them on server pubsub. leader handles these broadcasts and updates its own internal failure detectors.
    # leader also maintains failure detector state in redis so when leader changes the new leader can load existing fd data.
    # pushing fd state to redis is done async so redis can go down without killing detectors.
    class FailureDetector

      # one persister per client is entirely too many - this needs to be a pool
      include Persistence

      attr_reader :phi_threshold

      def initialize(name=nil, options = {})
        @name = name || SecureRandom.uuid
        @phi_threshold = options[:phi_threshold] || 8
        @intervals_size = options[:intervals_size] || 1000
      end

      def add(arrival_time = Time.now.to_i)
        #TODO this should really be multi/exec. last time should never be set without intervals.
        last_time = persister.getset(last_time_key, arrival_time)
        i = last_time.nil? ? 0.75 : arrival_time - last_time.to_i
        #TODO pipeline
        persister.lpush(intervals_key, i)
        persister.ltrim(intervals_key, 0, @intervals_size-1)
      end

      def phi(current_time = Time.now.to_i)
        last_time = persister.get(last_time_key)
        interval_mean = interval_mean
        return 0 unless last_time && interval_mean
        current_interval = current_time - last_time.to_i
        exp = -1 * current_interval / interval_mean
        -1 * (Math.log(Math::E ** exp) / Math.log(10))
      end

      def interval_mean
        intervals = intervals
        return nil unless intervals
        intervals.inject(:+) / intervals.size.to_f
      end

      def suspicious?
        phi > @phi_threshold
      end

      def intervals
        persister.lrange(intervals_key, 0, @intervals_size-1)
      end

      def last_time
        persister.get(last_time_key)
      end

      def last_time_key
        "fd:#{@name}:last_time"
      end

      def intervals_key
        "fd:#{@name}:intervals"
      end

      def clear
        #TODO multi/exec
        persister.del(last_time_key)
        persister.del(intervals_key)
      end
      
    end
  end
end
