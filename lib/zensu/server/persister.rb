require 'redis'

module Zensu
  module Server
    class Persister
      include Celluloid

      # TODO allow usage of fakeredis or even non-redis databases like zookeeper
      # could likely simulate all required redis ops with any consistent kv store

      REDIS_METHODS = %w(
        get
        set
        getset
        setnx
        del

        sadd
        smembers
        srem

        rpush
        lrange
        lpop
        ltrim

        hget
        hset
        hdel
        hgetall
        hexists
      )

      def initialize
        start_persistence_backend
      end

      def start_persistence_backend
        case Zensu.settings.persistence_backend
        when 'redis'
          environment = Zensu.settings.environment
          @namespace = "zensu_#{environment}"

          # symbolize keys
          redis_settings = Zensu.settings.redis.to_hash.inject({}) { |h,(k,v)| h[k.to_sym] = v; h }

          @backend = Redis.new(redis_settings)
        # when 'fakeredis'
          # require 'fakeredis'
          # # TODO not sure if this works. Probably needs a mutex around every request.
          # @backend = @@fakeredis
        else
          raise "unknown persistence backend"
          @backend = nil
        end
      end

      # TODO try to identify higher level operations that are composed of the above

      def namespace_key(key)
        "#{@namespace}:#{key}"
      end
    
      REDIS_METHODS.each do |method|
        define_method(method) do |*args|
          key = args.shift
          @backend.send(method, namespace_key(key), *args)
        end
      end
    end
  end
end
