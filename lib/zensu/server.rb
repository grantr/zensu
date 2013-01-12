require 'zensu/server/heart'
require 'zensu/server/broadcaster'

module Zensu
  module Server
    class App < Celluloid::SupervisionGroup
      supervise Heart, as: :heart
      supervise Broadcaster, as: :broadcaster
    end
  end
end
