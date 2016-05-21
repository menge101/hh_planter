# This class coordinates everything.  What seeds not planted, communicating with the google search
# and posting results to the redis queue
class Planter
  def initialize
    @db = DB
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
    # TODO
  end

  def find_seeds
    Seed.all
  end
end
