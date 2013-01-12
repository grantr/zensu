require 'zensu/stethoscope'
require 'zensu/subscriber'

module Zensu

  module Client
    class App < Celluloid::SupervisionGroup
      supervise Stethoscope, as: :stethoscope
      supervise Subscriber, as: :subscriber
    end
  end
end
