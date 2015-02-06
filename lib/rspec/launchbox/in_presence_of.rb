module RSpec
  module InPresenceOf
    def self.extended(*args)
      # Launches particular service
      # and makes sure it's dead afterwards.
      # @param [String] service
      # @yields block as `describe` does
      # @example
      #     describe MyClass do
      #       in_presence_of 'some_service' do
      #         # `some_service` executable is running
      #         it 'can establish connection' do
      #           #assert connecton presence
      #         end
      #         # and now it's being killed
      #       end
      #     end
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
