require "zensu/version"

require 'celluloid'
require 'ffi' # try to keep travis from missing ffi require
require 'celluloid/zmq'
require 'zensu/celluloid_ext'

Celluloid::ZMQ.init

require 'cabin'

require 'zensu/settings'

require 'zensu/rpc'
require 'zensu/rpc/ssl'
require 'zensu/rpc/encoding'
require 'zensu/rpc/dispatch'
require 'zensu/rpc/requester'
require 'zensu/rpc/handshake'

require 'zensu/server/response_router'
require 'zensu/server/broadcaster'
require 'zensu/server/puller'
require 'zensu/server/persister'
require 'zensu/server/failure_detector'

require 'zensu/client/pusher'
require 'zensu/client/command_pusher'
require 'zensu/client/keepalive_pusher'
require 'zensu/client/subscriber'

module Zensu
  class << self
    def settings=(settings)
      @settings = settings
    end

    def settings
      @settings ||= Zensu::Settings.new
    end

    def logger
      unless @logger
        log = Cabin::Channel.get
        log.subscribe(STDOUT)
        log.level = :debug #TODO configurable log level
        self.logger = log
      end
      @logger
    end

    # if logger = nil, make it a channel with no subscriptions
    def logger=(log)
      @logger = Celluloid.logger = (log ? log : Cabin::Channel.get) 
    end

   end
end
