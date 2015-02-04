describe '#persist' do
  context 'with jush value passed' do
    it 'raises exceptions' do
      expect(5).to persist 5
    end
  end
  context 'with block passed' do
    context 'with no boundary' do
      it 'd' do
        expect do
          'string'
        end.to persist
      end
    end

    context 'with boudary' do
      it 'succeeds' do
        expect do
          'string'
        end.to persist.at_most 1

        expect do
          'string'
          sleep 2
        end.to persist.at_least 1
      end
    end
  end

  context 'with block which raises exception' do
    it 'rethrows' do
      expect do
        'string'
        fail 'Exception in subject block'
      end.to persist
    end
  end
end
