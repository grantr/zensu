require "zensu/version"

require 'celluloid'
require 'celluloid/zmq'
require 'zensu/celluloid_ext'

Celluloid::ZMQ.init

require 'zensu/server/publisher'

require 'zensu/client/subscriber'

module Zensu
  # Your code goes here...
end
