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
      RSpec.describe "#{$_command_line} executable" do
        $_command_line = cmd
        $_process_stdout = ''

        before(:each) do
          $_process_pid = nil
          $_piper, $_pipew = IO.pipe
          $_process_pid = fork do
            $_piper.close
            $stdout.reopen $_pipew
            exec($_command_line)
          end
          $_pipew.close
          Thread.abort_on_exception = true
          Thread.new do
            until $_piper.eof?
              $_process_stdout << $_piper.read(16)
            end
          end
          sleep 1
        end

        after(:each) do
          `kill -INT #{$_process_pid} &>/dev/null`
          sleep 0.1
          `kill -KILL #{$_process_pid} &>/dev/null`
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

    # Waits for `timeout` seconds, then
    # sends signal to the process.
    # @param [Integer] timeout
    # @param [Hash] options
    # @option options [Symbol | String] signal
    # @example
    #     describe_executable 'some_long_running_executable' do
    #       running_for(10, signal: :INT) do
    #         its_stdout do
    #           #...
    #         end
    #       end
    #     end
    def running_for(timeout, options = {}, &block)
      $_signal = options[:signal] && options[:signal].to_s.upcase.prepend('-')
      context "when sent #{$_signal} after #{timeout} seconds" do
        before(:each) do
          Thread.new do
            sleep timeout
            `kill #{$_signal} #{$_process_pid} &>/dev/null`
          end.join
        end

        class_eval &block
      end
    end
  end
end
