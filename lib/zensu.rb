require "zensu/version"

require 'celluloid'
require 'celluloid/zmq'

require 'zensu/registry'
require 'zensu/configuration'
require 'zensu/configuration/local_node'
require 'zensu/remote_notifications'

require 'zensu/node'
require 'zensu/router'

module Zensu
  include Configurable

  class << self
    def node
      @node ||= Configuration::LocalNode.new
    end

    def nodes
      @nodes ||= NodeRegistry.new
    end
  end

  Logger = Celluloid::Logger
end

require 'zensu/client'
require 'zensu/server'

require 'zensu/boot'
