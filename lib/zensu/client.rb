require 'zensu/client/stethoscope'
require 'zensu/client/subscriber'

module Zensu

  module Client
    class App < Celluloid::SupervisionGroup
      supervise Stethoscope
      supervise Subscriber
    end
  end
end
