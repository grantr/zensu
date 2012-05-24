require 'benchmark'

module Zensu
  module Client
    class CommandPusher < CheckResultPusher

      def initialize(check, options={})
        super
        @command = options['command']
      end

      def check
        result = {}
        duration = Benchmark.realtime do
          ::IO.popen(@command + ' 2>&1') do |io|
            result['output'] = io.read
          end
        end
        result['status'] = $?.exitstatus
        result['duration'] = "%.3f" % duration.to_f

        result
      end
    end
  end
end
