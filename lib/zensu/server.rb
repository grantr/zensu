require 'zensu/heart'

module Zensu
  module Server
    class App < Celluloid::SupervisionGroup
      supervise Heart, as: :heart
    end
  end
end
