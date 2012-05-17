module Zensu
  module RPC
    module Encoding
      def encode(message)
        #TODO handle encryption
        MultiJson.dump(message.as_json)
      end

      def decode(message)
        #TODO handle encryption
        MultiJson.load(message)
      end
    end
  end
end
