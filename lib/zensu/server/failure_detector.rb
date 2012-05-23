module Zensu
  module Server

    # Inspired by cassandra's phi accrual failure detector
    #
    # TODO pipeline requests?
    class FailureDetector

      attr_reader :phi_threshold

      def initialize(name, options = {})
        @name = name
        @phi_threshold = options[:phi_threshold] || 8
        @persister = Persister.supervise
      end

      def add(arrival_time = Time.now.to_i)
        last_time = @persister.getset(last_time_key, arrival_time)
        i = last_time.nil? ? 0.75 : arrival_time - last_time
        @persister.lpush(intervals_key, i)
        @persister.ltrim(intervals_key, 1000)
      end

      def phi(current_time = Time.now.to_i)
        last_time = @persister.get(last_time_key)
        return 0 unless last_time
        current_interval = current_time - last_time
        exp = -1 * current_interval / interval_mean
        -1 * (Math.log(Math::E ** exp) / Math.log(10))
      end

      def interval_mean
        intervals = @persister.lrange(intervals_key, 1000)
        intervals.inject(:+) / intervals.size.to_f
      end

      def suspicious?
        phi > @phi_threshold
      end

      def last_time_key
        "fd_last_time:#{@name}"
      end

      def intervals_key
        "fd_intervals:#{@name}"
      end
      
    end
  end
end
