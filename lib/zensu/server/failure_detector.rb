module Zensu
  module Server

    # Inspired by cassandra's phi accrual failure detector
    #
    # TODO store/retrieve info in redis
    # maybe implement load/store
    # load grabs last_time and intervals from redis
    # store puts them there
    #
    # add appends to intervals list and updates last_time
    #
    # actually since this is 
    class RedisBackedFailureDetector

      attr_reader :last_time, :intervals
      attr_reader :phi_threshold

      def initialize(options = {})
        @last_time = nil
        @intervals = []
        @phi_threshold = options[:phi_threshold] || 8
      end

      def add(arrival_time = Time.now.to_i)
        last_time, @last_time = @last_time, arrival_time # TODO redis getset
        i = last_time.nil? ? 0.75 : arrival_time - last_time
        @intervals << i #TODO redis lpush
        @intervals.shift if @intervals.size > 1000 #TODO redis ltrim
      end

      def phi(current_time = Time.now.to_i)
        return 0 unless @last_time #TODO redis get
        current_interval = current_time - @last_time
        exp = -1 * current_interval / interval_mean
        -1 * (Math.log(Math::E ** exp) / Math.log(10))
      end

      def interval_mean
        @intervals.inject(:+) / @intervals.size.to_f #TODO redis lrange, llen
      end

      def suspicious?
        phi > @phi_threshold
      end
    end
  end
end
