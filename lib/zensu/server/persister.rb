require 'redis'
require 'redis-namespace'

module Zensu
  module Server
    class Persister
      include Celluloid

      def initialize
        environment = "development" #TODO configure environment
        namespace = "zensu_#{environment}" #TODO configure namespace

        redis = Redis::Namespace.new namespace, :redis => Redis.new #TODO configure redis
      end

      #TODO what is the api?
      #sensu uses:
      #
      # generally:
      # get
      # set
      # sadd
      # rpush
      # lrange
      # lpop
      # hget
      # hset
      # hdel
      #
      # for results:
      # sadd
      # rpush
      # lrange
      # lpop
      # hget
      # hset
      # hdel
      #
      # for keepalive:
      # smembers
      # hexists
      #
      # for election:
      # setnx
      # getset
      # del
    end
  end
end
