require 'hashie'
require 'multi_json'

module Zensu
  class Settings < Hashie::Mash
    def self.load_file(filename)
      new MultiJson.load(File.read(filename))
    end

    # TODO if there is no config, use default values.
    # it should work to install the gem and run the server and client without any other setup.
    # if redis is not configured, use a fakeredis persister. (with an appropriate warning against using this in production)

    def valid?
      #TODO validate required sections
      true
    end
  end
end
