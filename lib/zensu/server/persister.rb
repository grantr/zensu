require 'redis'
require 'redis-namespace'
require 'fakeredis' #TODO only require if no redis is configured

module Zensu
  module Server
    class Persister
      include Celluloid

      def initialize
        environment = "development" #TODO configure environment
        namespace = "zensu_#{environment}" #TODO configure namespace

        redis = Redis::Namespace.new namespace, :redis => Redis.new #TODO configure redis
      end

      # TODO allow usage of fakeredis or even non-redis databases like zookeeper
      # could likely simulate all required redis ops with any consistent kv store

      #TODO what is the api?
      #sensu server uses:
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
      #
      # sensu api uses:
      # smembers
      # get
      # hgetall
      # srem
      # del
    end
  end
end
