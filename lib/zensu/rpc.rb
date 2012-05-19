require 'securerandom'

module Zensu
  module RPC

    class Handler
      include Celluloid

      def respond(request)
        #TODO validate request, handle errors, etc
        handle(request)
      end
    end

    class Requester
      include Celluloid

    end

    module Envelope
      def envelope
        { 'jsonrpc' => '2.0' }
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
    end

    class Request < Notification
      attr_accessor :id

      def self.parse(body)
        new body['method'], body['params'], body['id']
      end

      def initialize(method, params, id=nil)
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
    end
    
  end
end
