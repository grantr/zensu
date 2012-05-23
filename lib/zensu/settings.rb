require 'hashie'
require 'multi_json'

module Zensu
  class Settings < Hashie::Mash
    def self.load(filename)
      parse File.read(filename)
    end
    
    def self.parse(string)
      new MultiJson.load(string)
    end

    # TODO if there is no config, use default values.
    # it should work to install the gem and run the server and client without any other setup.
    # if redis is not configured, use a fakeredis persister. (with an appropriate warning against using this in production)
    #
    # TODO this might be a good place to add internal pubsub based on watching config values

    def valid?
      #TODO validate required sections
      true
    end

    def servers
      @servers ||= (self['servers'] ? self['servers'].collect { |s| Server.new(s) } : [server])
    end

    def checks
      self['checks'] ||= {}
    end

    def handlers
      self['handlers'] ||= {}
    end

    def ssl
      @ssl ||= SSL.new(self['ssl'])
    end

    class SSL < Hashie::Mash
      #TODO if relative paths join with top level config path
      #TODO should these raise on missing or return nil or empty string?
      def certificate
        self['certificate'] ||= File.read(cert_file)
      end

      def cacert
        self['cacert']||= File.read(cacert_file)
      end

      def private_key
        self['private_key'] ||= File.read(key_file)
      end

      def cipher
        self['cipher'] ||= 'AES-256-CBC'
      end

    end

    def client
      @client ||= Client.new(self['client'])
    end

    class Client < Hashie::Mash
      def name
        self['name'] ||= "unknown"
      end
    end

    def server
      @server ||= Server.new(self['server'])
    end

    class Server < Hashie::Mash
      def host
        self['host'] ||= '127.0.0.1'
      end

      def broadcast_port
        self['broadcast_port'] ||= "5565"
      end

      def results_port
        self['results_port'] ||= "5566"
      end

      def rpc_port
        self['rpc_port'] ||= "5567"
      end

    end

    def default_check_interval
      60
    end
  end
end
