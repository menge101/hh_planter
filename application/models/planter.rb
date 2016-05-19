require 'pg'
require 'sequel'
require 'sequel/extensions/migration'
require 'yaml'

# This class coordinates everything.  What seeds not planted, communicating with the google search
# and posting results to the redis queue
class Planter

  def initialize(mode=ENVIRONMENT)
    @db = Sequel.postgres(DB_CONFIG[mode])
    Sequel::Migrator.check_current(@db, MIGRATION_LOCATION)
  end

  def plant

  end

  private

  def query_custom_search(term)

  end

  def find_seeds

  end

end
