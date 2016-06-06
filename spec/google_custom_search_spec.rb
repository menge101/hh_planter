RSpec.describe GoogleCustomSearch do
  before(:each) do
    GCS_CONFIG = YAML.load_file(File.join(PROJECT_ROOT, 'config', 'secrets.yml'))['google'].freeze
    @search = GoogleCustomSearch.new(GCS_CONFIG['custom_search_api'],
                                     GCS_CONFIG['engine_id'])
    FakeWeb.register_uri(:get, 'https://www.googleapis.com/customsearch/v1', body: 'yo.')
  end

  context 'when I query pittsburgh' do
    let (:term) { 'pittsburgh' }
    it 'gets a 200 response' do
      last_response = @search.search(term)
      expect(last_response.code).to eq 200
    end
  end
end