require 'httparty'
# This is a gateway class that facilitates communication with Google Custom Search

class GoogleCustomSearch
  include HTTParty
  base_uri 'https://www.googleapis.com/customsearch/v1'

  def initialize(api_key, engine_id)
    @credentials = {key: api_key, cx: engine_id }
  end

  def search(query)
    options = { q: query }
    options.merge! @credentials
    self.class.get('', options)
  end
end
