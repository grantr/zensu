require "zensu/version"

require 'celluloid'
require 'celluloid/zmq'

require 'zensu/configuration'
require 'zensu/remote_notifications'

require 'zensu/node'

module Zensu
  include Configurable

  class << self
    def node
      @node ||= Node.new
    end

    def nodes
      @nodes ||= Registry.new
    end
  end

  Logger = Celluloid::Logger
end

require 'zensu/client'
require 'zensu/server'

require 'zensu/boot'
