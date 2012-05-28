require 'securerandom'

module Zensu
  module RPC
    VERSION_STRING = '1.0.0'

    class Responder
      include Celluloid

      def respond(request)
        #TODO validate request, handle errors, etc
        generate_response(request)
      end
    end

    module Envelope
      def envelope
        # v is using semantic versioning
        # major bump: backwards incompatible
        # minor bump: backwards compatible with new features
        # patch bump: backwards compatible bug fixes
        { 'jsonrpc' => '2.0', 'v' => VERSION_STRING }
      end

      def plaintext?
        @plaintext
      end

      def plaintext=(plaintext)
        @plaintext = plaintext
      end
    end

    Notification = Struct.new(:method, :params) do
      include Envelope

      def self.parse(body)
        new body['method'], body['params']
      end

      def as_json
        envelope.tap do |h|
          h['method'] = method
          h['params'] = params if !params.nil? && !params.empty?
        end
      end

      def method_missing(method, *args, &block)
        if params.respond_to?(:has_key?) && params.has_key?(method.to_s) && args.empty?
          params[method.to_s]
        else
          super
        end
      end

    end

    class Request < Notification
      attr_accessor :id

      def self.parse(body)
        new body['method'], body['params'], body['id']
      end

      def initialize(method, params=nil, id=nil)
        super(method, params)
        self.id = id || SecureRandom.uuid
      end

      def as_json
        super.tap do |h|
          h['id'] = id
        end
      end
    end

    Response = Struct.new(:result, :error, :id) do
      include Envelope

      def self.parse(body)
        new body['result'], body['error'], body['id']
      end

      def as_json
        envelope.tap do |h|
          h['result'] = result if success?
          h['error'] = error if error?
          h['id'] = id
        end
      end

      def error?
        !error.nil?
      end

      def success?
        !result.nil?
      end

      def method_missing(method, *args, &block)
        if result.respond_to?(:has_key?) && result.has_key?(method.to_s) && args.empty?
          result[method.to_s]
        else
          super
        end
      end
    end
    
  end
end
