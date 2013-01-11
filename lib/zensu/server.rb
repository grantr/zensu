require 'zensu/server/heart'
require 'zensu/server/broadcaster'

module Zensu
  module Server
    class App < Celluloid::SupervisionGroup
      #TODO settings or inherit
      supervise Celluloid::ZMQ::PubsubNotifier, as: :remote_notifier, args: ["tcp://127.0.0.1:58001"]
      supervise Heart
      supervise Broadcaster
    end
  end
end
