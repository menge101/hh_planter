RSpec.describe Planter do
  context 'with 1 unplanted seed' do
    let(:seed) { FactoryGirl.create(:seed) }
    it 'plants the seed' do
      Timecop.freeze(Time.now) do
        seed.plant
        expect(seed.last_planted).to_be Time.now
      end
    end
  end
end
