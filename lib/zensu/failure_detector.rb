module Zensu
  class FailureDetector

    attr_reader :last_time, :intervals
    attr_reader :phi_threshold

    def initialize(options = {})
      @last_time = nil
      @intervals = []
      @phi_threshold = options[:phi_threshold] || 8
    end

    def add(arrival_time = Time.now.to_i)
      last_time, @last_time = @last_time, arrival_time
      i = last_time.nil? ? 0.75 : arrival_time - last_time
      @intervals << i
      @intervals.shift if @intervals.size > 1000
    end

    def phi(current_time = Time.now.to_i)
      return 0 unless @last_time
      current_interval = current_time - @last_time
      exp = -1 * current_interval / interval_mean
      -1 * (Math.log(Math::E ** exp) / Math.log(10))
    end

    def interval_mean
      @intervals.inject(:+) / @intervals.size.to_f
    end

    def suspicious?
      phi > @phi_threshold
    end

    def empty?
      @intervals.empty?
    end
  end
end
