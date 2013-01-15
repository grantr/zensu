module Zensu
  class Message
    VERSION = "1"

    attr_accessor :id, :headers, :version, :args

    def initialize(id=nil, headers=[], args=[], version=VERSION)
      @id = id || Celluloid::UUID.generate
      @headers = headers
      @args = args
      @version = version
    end

    # Should headers be a single hash or an array?
    def self.parse(parts)
      message = new
      parts = parts.dup
      message.version = parts.shift

      #TODO branch on version here

      message.id = parts.shift

      while (header = parts.shift) != ""
        message.headers << header
      end

      message.args = parts
    end

    def to_parts
      [
       version,
       id,
       *headers.collect(&:to_s),# json?
       "",
       *args.collect(&:to_s)] # json?
    end
  end
end
