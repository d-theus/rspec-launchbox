module RSpec
  # #describe_executable method and some
  # pretty expectations regarding streams.
  module DescribeExecutable
    # Expectations regarding streams,
    # i.e. stderr, stdout.
    # Meant to be extended in #describe_stderr and
    # #describe_stdout
    module Stream
      # Expects lines in the specified stream
      # to include each of the specified lines
      # @param [Array] lines
      # @example
      #     describe_stderr do
      #       it_is_expected_to_have_line 'cannot load shared library'
      #     end
      def it_is_expected_to_have_line(*lines)
        it "is expected to have line(s) matching '#{lines}'" do
          expect(_watch_stream.lines.map(&:chomp)).to include *lines
        end
      end

      alias_method :it_is_expected_to_have_lines, :it_is_expected_to_have_line
      alias_method :has_line, :it_is_expected_to_have_lines
      alias_method :has_lines, :it_is_expected_to_have_line

      # Expects some lines in the specified stream
      # to match specified pattern
      # @param [Regex, String] lines
      # @see #it_is_expected_to_have_line
      def it_is_expected_to_have_lines_matching(pat)
        it "is expected to have line(s) matching pattern '#{pat}'" do
          __grep = _watch_stream.lines.grep(pat)
          expect(__grep.size).to be > 0
        end
      end

      alias_method :has_line_matching, :it_is_expected_to_have_lines_matching

      # Expects lines in the specified stream
      # *not* to include each of the specified lines
      # @param [Regex, String] lines
      # @see #it_is_expected_to_have_line
      def it_is_expected_not_to_have_line(*lines)
        it "is expected not to have line(s) matching '#{lines}'" do
          expect(_watch_stream.lines.map(&:chomp)).not_to include *lines
        end
      end

      alias_method :it_is_expected_not_to_have_lines, :it_is_expected_not_to_have_line
      alias_method :has_no_line, :it_is_expected_not_to_have_line

      # Expects *none of* the lines in the specified stream
      # to match specified pattern
      # @param [Regex, String] lines
      # @see #it_is_expected_to_have_line
      def it_is_expected_not_to_have_lines_matching(pat)
        it "is expected not to have line(s) matching pattern '#{pat}'" do
          __grep = _watch_stream.lines.grep(pat)
          expect(__grep.size).to be 0
        end
      end

      alias_method :has_no_line_matching, :it_is_expected_not_to_have_lines_matching
    end

    # Outmost describe block.
    # @param [String] cmd executable name
    # @yields block like ordinary #describe
    # @example
    #     describe_executable 'ls' do
    #       describe_stdout do
    #         it { is_expected.to be_a String }
    #       end
    #     end
    def describe_executable(cmd, &block)
      RSpec.describe "#{$_command_line} executable" do
        $_command_line = cmd
        $_flags = []
        $_process_stdout = ''
        $_process_stderr = ''

        before(:each) do
          $_command_line = cmd
          $_process_stdout = ''
          $_process_pid = nil
          $_piper_o, $_pipew_o = IO.pipe
          $_piper_e, $_pipew_e = IO.pipe
          $_process_pid = fork do
            $_piper_o.close
            $_piper_e.close
            $stdout.reopen $_pipew_o
            $stderr.reopen $_pipew_e
            exec($_command_line + ' ' + $_flags.join(' '))
          end
          $_pipew_o.close
          $_pipew_e.close
          Thread.abort_on_exception = true
          Thread.new do
            maybe_read = [$_piper_o, $_piper_e]
            can_read = []
            loop do
              can_read = select([$_piper_o, $_piper_e]).first.map!(&:fileno)
              $_process_stdout << ($_piper_o.read(16) || '') if can_read.include? $_piper_o.fileno
              $_process_stderr << ($_piper_e.read(16) || '') if can_read.include? $_piper_e.fileno
              maybe_read.delete_if { |io| io.eof? }
              break if maybe_read.empty?
            end
          end.join
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
    def describe_stdout(&block)
      describe "it's stdout" do
        let(:_watch_stream) { $_process_stdout.dup }
        extend Stream

        subject { $_process_stdout }

        class_eval &block
      end
    end

    # Same as #describe_stdout
    # for stderr
    def describe_stderr(&block)
      describe "it's stderr" do
        let(:_watch_stream) { $_process_stderr.dup }
        extend Stream

        subject { $_process_stderr }

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
    #         describe_stdout do
    #           #you need rspec-its gem for `its`
    #           its(:lines) { is_expected.to include ".\n" }
    #           # much prettier:
    #           has_line '.'
    #         end
    #       end
    #     end
    def given_option(flag, &block)
      context "given option #{flag}" do
        before(:context) do
          $_flags << flag
        end

        after(:context) do
          $_flags.pop
        end

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
    #         describe_stdout do
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
