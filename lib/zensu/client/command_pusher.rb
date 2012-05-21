module Zensu
  module Client
    class CommandPusher < Pusher

      def initialize(check, options={})
        super
        @command = options['command']
      end

      def check
        result = {}
        ::IO.popen(@command + ' 2>&1') do |io|
          result['output'] = io.read
        end
        result['status'] = $?.exitstatus

        push result
      end
    end
  end
end
