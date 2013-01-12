require 'zensu/server/heart'
require 'zensu/server/broadcaster'

module Zensu
  module Server
    class App < Celluloid::SupervisionGroup
      supervise Heart
      supervise Broadcaster
    end
  end
end
