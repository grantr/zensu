require 'benchmark'

module Zensu
  module Client
    class CommandPusher < CheckResultPusher

      #TODO add variable substitution

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
        # $? is threadsafe according to http://stackoverflow.com/questions/2164887/thread-safe-external-process-in-ruby-plus-checking-exitstatus
        result['status'] = $?.exitstatus
        result['duration'] = "%.3f" % duration

        result
      end
    end
  end
end
