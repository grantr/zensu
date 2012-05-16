require 'hashie'
require 'multi_json'

module Zensu
  class Settings < Hashie::Mash
    def self.load_file(filename)
      new MultiJson.load(File.read(filename))
    end

    def valid?
      #TODO validate required sections
      true
    end
  end
end
