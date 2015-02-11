require "rspec/launchbox/version"
require 'timeout'
require 'rspec/its'

require 'rspec/launchbox/timeout_matchers.rb'
require 'rspec/launchbox/in_presence_of.rb'
require 'rspec/launchbox/describe_executable.rb'

include RSpec::DescribeExecutable
RSpec.configure do |c|
  c.extend RSpec::InPresenceOf
  c.include RSpec::Matchers::Timeout
end
