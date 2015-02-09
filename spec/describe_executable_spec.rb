describe_executable 'ls' do
  its_stdout do
    it { is_expected.to be_a String }
    it { is_expected.not_to be_empty }
  end

  given_option '-a' do
    its_stdout do
      it { is_expected.to be_a String }
      its(:lines) { is_expected.to include ".\n" }
      its(:lines) { is_expected.not_to include "ohwowwhatisit\n" }
    end
  end

  running_for(10, signal: :INT) do
    its_stdout do
      it { is_expected.to be_a String }
    end
  end
end
