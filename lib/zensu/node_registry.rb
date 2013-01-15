module Zensu
  # like a normal registry, but always has a local node with the local id
  class NodeRegistry < Registry
    def get(key)
      @_lock.synchronize do
        if key == Zensu.node.id
          # note that this is not published, only available when requested
          fetch(key.to_sym, nil) || store(key.to_sym, Node.new(Zensu.node.id))
        else
          fetch(key.to_sym, nil)
        end
      end
    end
  end
end
