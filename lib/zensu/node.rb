require 'zensu/failure_detector'

module Zensu
  class Node
    include Celluloid
    include Celluloid::FSM
    include Celluloid::Notifications

    CHECK_INTERVAL = 1 #TODO config

    state :unknown, default: true
    state :up do
      notify_state(:up)
    end
    state :down do
      notify_state(:down)
    end

    attr_accessor :id, :fd

    def initialize(id=nil, options = {})
      super()
      @id = id || Celluloid::UUID.generate
      @fd = FailureDetector.new
      attach Actor.current
    end

    def beat_heart
      if @fd.empty?
        @timer = every(CHECK_INTERVAL) { check }
      end
      @fd.add(Time.now.to_i)
    end

    def check
      if @fd.suspicious?
        transition :down if state != :down
      else
        transition :up if state != :up
      end
    end

    def notify_state(state)
      Logger.info "#{@id} #{state}"
      publish("zensu.node.state.#{@id}", state)
    end

    # overridden because inspect causes stack overflow
    # TODO why?
    def inspect
      "Node"
    end
  end
end
