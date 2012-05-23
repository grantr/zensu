module Zensu
  module Server

    def self.run
      Zensu.setup
      Group.run
    end

    def self.run!
      Zensu.setup
      Group.run!
    end


    class Group < Celluloid::Group
      supervise Elector
      supervise Puller
      supervise ResponseRouter
    end
  end
end
