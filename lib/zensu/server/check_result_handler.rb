module Zensu
  module Server
    class CheckResultHandler
      include Celluloid

      def handle(message)
        Zensu.logger.debug("handling check result: #{message}")
      end
    end
  end
end
