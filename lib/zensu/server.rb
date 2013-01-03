module Zensu
  module Server

    def self.run(options={})
      Zensu.setup(options)
      App.run
    end

    def self.run!(options={})
      Zensu.setup(options)
      App.async.run
    end


    class App < Celluloid::SupervisionGroup
      supervise Coordinator
      supervise Puller
      supervise ResponseRouter
    end
  end
end
