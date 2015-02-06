module RSpec
  module DescribeExecutable
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

    def its_stdout(&block)
      describe "it's stdout" do
        subject { $_process_stdout }

        class_eval &block
      end
    end

    def given_option(flag, parameter = nil, &block)
      context "given option #{flag}#{parameter ? parameter + ' ' : nil}" do
        $_command_line__old = $_command_line.dup
        $_command_line << ' ' << [flag, parameter].join(' ')

        class_eval &block
      end
    end
  end
end
