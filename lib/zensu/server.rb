module Zensu
  module Server

    def self.run(options={})
      Zensu.setup(options)
      Group.run
    end

    def self.run!(options={})
      Zensu.setup(options)
      Group.run!
    end


    class Group < Celluloid::Group
      supervise Coordinator
      supervise Puller
      supervise ResponseRouter
    end
  end
end
