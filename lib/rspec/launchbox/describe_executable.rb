module RSpec
  module DescribeExecutable
    # Outmost describe block.
    # @param [String] cmd executable name
    # @yields block like ordinary #describe
    # @example
    #     describe_executable 'ls' do
    #       its_stdout do
    #         it { is_expected.to be_a String }
    #       end
    #     end
    def describe_executable(cmd, &block)
      $_command_line = cmd
      $_process_stdout = ''
      RSpec.describe "#{$_command_line} executable" do
        before(:each) do
          Thread.abort_on_exception = true
          Thread.new do
            IO.popen($_command_line) do |io|
              $_process_stdout << io.read(256) until io.eof?
            end
          end
          sleep 1
        end

        after(:each) do
          `killall -INT #{$_command_line.split(/\W/)[0]} &>/dev/null`
          sleep 0.1
          `killall -KILL #{$_command_line.split(/\W/)[0]} &>/dev/null`
        end

        class_eval &block
      end
    end

    # Opens new 'describe',
    # sets it's subject to process stdout
    # @yields block like ordinary describe
    # @see #describe_executable for an example
    def its_stdout(&block)
      describe "it's stdout" do
        subject { $_process_stdout }

        class_eval &block
      end
    end

    # Opens new 'context',
    # where options are appended to
    # command line before execution.
    # @param [String] flag e.g. `-f`
    # @param [String] parameter
    # @example
    #     describe_executable 'ls' do
    #       given_option '-a' do
    #         its_stdout do
    #           #you need rspec-its gem for `its`
    #           its(:lines) { is_expected.to include ".\n" }
    #         end
    #       end
    #     end
    def given_option(flag, parameter = nil, &block)
      context "given option #{flag}#{parameter ? parameter + ' ' : nil}" do
        $_command_line__old = $_command_line.dup
        $_command_line << ' ' << [flag, parameter].join(' ')

        class_eval &block
      end
    end
  end
end
