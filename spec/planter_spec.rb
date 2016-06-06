RSpec.describe Planter do
  before(:each) do
    config = YAML.load_file(File.join(PROJECT_ROOT, 'config', 'secrets.yml'))['google'].freeze
    search = GoogleCustomSearch.new(config['custom_search_api'],
                                    config['engine_id'])
    @planter = Planter.new(DB,search,nil)
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
