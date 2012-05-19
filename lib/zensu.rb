require "zensu/version"

require 'celluloid'
require 'celluloid/zmq'
require 'zensu/celluloid_ext'

Celluloid::ZMQ.init

require 'zensu/settings'

require 'zensu/rpc'
require 'zensu/rpc/encoding'
require 'zensu/rpc/ssl'
require 'zensu/rpc/handshake'

require 'zensu/server/responder'
require 'zensu/server/publisher'
require 'zensu/server/puller'

require 'zensu/client/requester'
require 'zensu/client/pusher'
require 'zensu/client/subscriber'

module Zensu
  def self.settings=(settings)
    @settings = settings
  end

  def self.settings
    @settings
  end
end
