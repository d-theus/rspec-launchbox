describe 'Presence command' do
  cmd = 'cat'
  in_presence_of cmd do
    it 'ps shows presence of command' do
      expect(`ps -A | grep #{cmd}`.lines.any?).to be_truthy
    end
  end
end
