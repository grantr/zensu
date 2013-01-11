require "zensu/version"

require 'celluloid'
require 'celluloid/zmq'

require 'zensu/settings'
require 'zensu/remote_notifications'

module Zensu
  class << self
    def id
      @id ||= Celluloid::UUID.generate #TODO
    end
  end
end

require 'zensu/client'
require 'zensu/server'

require 'zensu/boot'
