module RSpec
  module InPresenceOf
    def self.extended(*args)
      def in_presence_of(service, &block)
        before do
          @_service_pid = fork do
            $stdout.reopen '/dev/null'
            $stderr.reopen '/dev/null'
            exec service
          end
          fail "Failed to execute #{service}" unless @_service_pid
        end

        after do
          Process.kill(:INT, @_service_pid) if @_service_pid
        end

        context("in presence of #{service} service", &block)
      end
    end
  end
end
