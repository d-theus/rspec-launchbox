module RSpec
  module Launchbox
    RSpec::Matchers.define :persist do
      supports_block_expectations
      @should_complete_block = nil

      chain :at_least do |time|
        @time = time
        @should_complete_block = false
      end

      chain :at_most do |time|
        @time = time
        @should_complete_block = true
      end

      match do |actual|
        fail "Block expected, got #{actual.class}" unless actual.respond_to? :call 
        fail "Expected 'persist.at_least(<seconds>)' or 'persist.at_most(<seconds>)'" if @should_complete_block.nil?
        begin
          Timeout.timeout(@time, &actual)
          @block_complete = true
        rescue Timeout::Error
          @block_complete = false
        end
        @block_complete == @should_complete_block
      end
    end
  end
end
