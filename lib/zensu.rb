require "zensu/version"

require 'celluloid'
require 'celluloid/zmq'
require 'zensu/celluloid_ext'

Celluloid::ZMQ.init

require 'cabin'

require 'zensu/settings'

require 'zensu/rpc'
require 'zensu/rpc/encoding'
require 'zensu/rpc/ssl'
require 'zensu/rpc/handshake'

require 'zensu/server/response_router'
require 'zensu/server/publisher'
require 'zensu/server/puller'

require 'zensu/client/request_router'
require 'zensu/client/pusher'
require 'zensu/client/subscriber'

module Zensu
  def self.settings=(settings)
    @settings = settings
  end

  def self.settings
    @settings
  end

  def self.logger
    @logger ||= Cabin::Channel.get
    @logger.subscribe(STDOUT)
    @logger.level = :debug #TODO configurable log level
    @logger
  end
end
