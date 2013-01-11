require 'zensu/server/heart'
require 'zensu/server/broadcaster'

module Zensu
  module Server
    class App < Celluloid::SupervisionGroup
      supervise RemoteNotifier, as: :remote_notifier
      supervise Heart
      supervise Broadcaster
    end
  end
end
