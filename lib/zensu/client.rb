require 'zensu/client/stethoscope'

module Zensu
  module Client
    class App < Celluloid::SupervisionGroup
      #TODO settings, or inherit
      supervise Celluloid::ZMQ::PubsubNotifier, as: :broadcast_notifier, args: [nil, ["tcp://127.0.0.1:58001"]]
      supervise Stethoscope
    end
  end
end
