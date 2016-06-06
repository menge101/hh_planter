# This class coordinates everything.  What seeds not planted, communicating with the google search
# and posting results to the redis queue
class Planter
  def initialize(database, query_gateway, redis_conn)
    @db = database
    @search = query_gateway
    @queue = redis_conn
  end

  def plant
    seeds_to_plant = find_seeds
    seeds_to_plant.each do |seed|
      seed.last_planted = Time.now
      seed.save
    end
  end

  private

  def query_custom_search(term)
    @search.search(term)
  end

  def find_seeds
    Seed.all
  end
end
