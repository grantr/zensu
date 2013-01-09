require 'zensu/server/heart'

module Zensu
  module Server
    class App < Celluloid::SupervisionGroup
      #TODO settings or inherit
      supervise Celluloid::ZMQ::PubsubNotifier, as: :broadcast_notifier, args: ["tcp://127.0.0.1:58001"]
      supervise Heart
    end
  end
end
