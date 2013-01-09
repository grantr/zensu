require "zensu/version"

require 'celluloid'
require 'celluloid/zmq'

require 'celluloid/zmq/pubsub_notifier'
require 'celluloid/zmq/extra_sockets'

require 'zensu/settings'
require 'zensu/broadcast'

module Zensu
  class << self
    def id
      '1' #TODO
    end
  end
end

require 'zensu/client'
require 'zensu/server'

require 'zensu/boot'
