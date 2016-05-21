RSpec.describe Planter do
  before(:each) do
    @planter = Planter.new
  end

  context 'with 1 unplanted seed' do
    let(:seed) { FactoryGirl.create(:seed) }
    it 'plants the seed' do
      expect(seed.last_planted).to be_nil
      Timecop.freeze(Time.now) do
        @planter.plant
        expect(seed.refresh.last_planted).to eq Time.now
      end
    end
  end

  context 'when configured to replant every 30 days' do
    context 'with 1 seed planted 31 days ago' do
      let(:seed) { FactoryGirl.create(:seed, :planted_31_days_ago) }
      it 'plants the seed' do
        expect(seed.last_planted).to_not be_nil
        Timecop.freeze(Time.now) do
          @planter.plant
          expect(seed.refresh.last_planted).to eq Time.now
        end
      end
    end
  end
end
