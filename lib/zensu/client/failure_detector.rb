module Zensu
  module Client
    class FailureDetector
      include Celluloid
      include Celluloid::FSM
      include Celluloid::Notifications

      attr_reader :last_time, :intervals
      attr_reader :phi_threshold

      CHECK_INTERVAL = 1 #TODO setting

      state :unknown, default: true
      state :up do
        notify_up
      end
      state :down do
        notify_down
      end

      def initialize(id, options = {})
        @id = id
        @last_time = nil
        @intervals = []
        @phi_threshold = options[:phi_threshold] || 8
        attach self
        every(CHECK_INTERVAL) { check }
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

      def check
        if suspicious?
          transition :down if state != :down
        else
          transition :up if state != :up
        end
      end

      def notify_up
        puts "#{@id} up"
        publish("zensu.server.state.#{@id}", :up)
      end

      def notify_down
        puts "#{@id} down"
        publish("zensu.server.state.#{@id}", :down)
      end


      def inspect
        "fd" #TODO causes a stack overflow
      end

    end
  end
end
