describe '#persist' do
  context 'with jush value passed' do
    it 'raises exceptions' do
      begin
        expect(5).to persist 5
      rescue RuntimeError => e
        raise e unless e.message.include? 'Block expected'
      end
    end
  end
  context 'with block passed' do
    context 'with no boundary' do
      it 'd' do
        begin
          expect do
            'string'
          end.to persist
        rescue RuntimeError => e
          raise e unless e.message.include? 'Expected'
        end
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
      begin
        expect do
          'string'
          fail 'Exception in subject block'
        end.to persist.at_most(1)
      rescue RuntimeError => e
        raise e unless e.message.include? 'Exception in subject block'
      end
    end
  end
end
