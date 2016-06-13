require_relative '../../config/database'

# This class represents the searchable term
class Seed < Sequel::Model
  Seed.plugin :timestamps
end
