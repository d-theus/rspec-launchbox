describe_executable 'ls' do
  describe_stdout do
    it { is_expected.to be_a String }
    it { is_expected.not_to be_empty }
    it_is_expected_to_have_line 'spec'
    it_is_expected_to_have_line 'spec', 'lib'
    it_is_expected_not_to_have_line 'blaargs'
    it_is_expected_to_have_lines_matching /spec/
    it_is_expected_not_to_have_lines_matching /blaargh/
  end

  given_option '-a' do
    describe_stdout do
      it { is_expected.to be_a String }
      its(:lines) { is_expected.to include ".\n" }
      its(:lines) { is_expected.not_to include "ohwowwhatisit\n" }
    end
  end

  given_option '-h' do
    describe_stdout do
      it 'command line should be cleaned up after each example' do
        expect($_command_line).not_to include '-a'
      end
      its(:lines) { is_expected.not_to include ".\n" }
    end

    given_option '-a' do
      describe_stdout do
        its(:lines) { is_expected.to include ".\n" }
      end
    end
  end

  given_option '1>&2' do
    describe_stderr do
      its(:lines) { is_expected.to include "spec\n" }
    end
  end

  running_for(2, signal: :INT) do
    describe_stdout do
      it { is_expected.to be_a String }
    end
  end
end
