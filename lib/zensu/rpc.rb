require 'securerandom'

module Zensu
  module RPC

    module Envelope
      def envelope
        { 'jsonrpc' => '2.0' }
      end
    end

    #TODO we need the ability to declare requests and responses.
    
    # HandshakeRequest
    #   # param defines a key in the params hash
    #   param :cert, required: true
    #   param :name
    #
    #   method 'auth' # method is automatically validated
    #
    #   validate do
    #     # check params
    #   end
    #
    #
    # HandshakeResponse
    #  # result defines a key in the results hash
    #  result :cert, required: true
    #  result :shared_key
    #
    #  validate do
    #    # check results
    #  end
    #
    #  on_error 'blah' do
    #    # do something, maybe raise
    #  end
    #
    #  on_error /blah/ => 'error string' # set error string

    Notification = Struct.new(:method, :params) do
      include Envelope

      def self.parse(body)
        Notification.new body['method'], body['params']
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
        Request.new body['method'], body['params'], body['id']
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
        Response.new body['result'], body['error'], body['id']
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
