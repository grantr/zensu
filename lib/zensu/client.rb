require 'zensu/stethoscope'

module Zensu

  module Client
    class App < Celluloid::SupervisionGroup
      supervise Stethoscope, as: :stethoscope
    end
  end
end
