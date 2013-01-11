require 'zensu/client/stethoscope'
require 'zensu/client/subscriber'

module Zensu
  module Client
    class App < Celluloid::SupervisionGroup
      #TODO settings, or inherit
      supervise Celluloid::ZMQ::PubsubNotifier, as: :remote_notifier, args: [nil, ["tcp://127.0.0.1:58001"]]
      supervise Stethoscope
      supervise Subscriber
    end
  end
end
