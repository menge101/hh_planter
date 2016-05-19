require 'pg'
require 'sequel'
require 'sequel/extensions/migration'
require 'yaml'

CONFIG_FILE = (PROJECT_ROOT + '/config/database.yml').freeze
raise "Config file not found.
Config file must be located at #{CONFIG_FILE}" unless File.exist?(CONFIG_FILE)
DB_CONFIG = YAML.load_file(CONFIG_FILE).freeze
CX_ID = ENV['CX'].freeze
MIGRATION_LOCATION = File.join(PROJECT_ROOT, DB_CONFIG[ENVIRONMENT]['migration_location']).freeze
DB = Sequel.postgres(DB_CONFIG[ENVIRONMENT])
Sequel::Migrator.check_current(DB, MIGRATION_LOCATION)
