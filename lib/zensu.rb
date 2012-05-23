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
require 'zensu/server/keepalive_handler'
require 'zensu/server/check_result_handler'
require 'zensu/server'

require 'zensu/client/pusher'
require 'zensu/client/command_pusher'
require 'zensu/client/keepalive_pusher'
require 'zensu/client/subscriber'
require 'zensu/client'

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

    def setup
      load_settings
    end

    def load_settings
      config_paths = [
        "/etc/zensu",
        "/etc/sensu",
        File.join(File.dirname(__FILE__), '..', 'examples')
      ]
      path = config_paths.detect { |p| File.exist?(File.join(p, "config.json")) }
      
      self.settings = Zensu::Settings.load(File.join(path, "config.json"))

      #TODO conf.d
    end
  end
end
