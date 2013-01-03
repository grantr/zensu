require 'redis'

module Zensu
  module Server
    module Persistence
      def persister
        @persister_supervisor ||= Persister.supervise
        @persister_supervisor.actor
      end
    end

    class Persister
      include Celluloid

      # TODO allow usage of fakeredis or even non-redis databases like zookeeper
      # could likely simulate all required redis ops with any consistent kv store
      #
      # data structures:
      # clients:
      # individual client data
      # clients set (index)
      # 
      # aggregates: (aggregate check results across clients)
      # aggregate per check/timestamp pair
      # per-status/total counter increments
      # set of timestamps per check
      # checks set
      #
      # history:
      # set of checks received for a client
      # time-ordered list of statuses for each client/check pair
      #   recent-item list scan to detect flapping
      #   trim old list events
      #
      # events:
      # one event per client/check pair
      #
      # master election:
      #   set if not exist
      #   atomic getset
      
      # This could probably be remodeled intelligently as:
      # Client
      #   has_many :checks
      #
      # Check
      #   belongs_to :client
      #   has_many :check_results
      #
      #   event data is on this record
      #
      # CheckResult
      #   belongs_to :check
      #
      # Aggregate
      #   has_many :checks
      # aggregation should probably be a handler
      #

      REDIS_METHODS = %w(
        get
        set
        getset
        setnx
        del
        exists

        sadd
        smembers
        srem

        rpush
        lpush
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

      # def pipelined(&block)
      #   @backend.pipelined(&block)
      # end
    end
  end
end
