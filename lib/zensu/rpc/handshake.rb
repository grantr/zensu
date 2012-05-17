module Zensu
  module RPC
    module Handshake
      #TODO request and response should probably be modules
      class HandshakeRequest < Request
        def initialize(name, cert)
          super('handshake', { 'name' => name, 'cert' => cert  })
        end
      end

      class HandshakeResponse < Response
        #TODO handle errors
        def initialize(cert, shared_key, id)
          super({ 'cert' => cert, 'shared_key' => shared_key }, nil, id)
        end
      end
    end
  end
end
