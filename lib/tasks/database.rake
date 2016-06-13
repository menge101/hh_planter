# This file contains rake tasks for working with database.
require 'yaml'
require 'fileutils'

def db_uri
  dbconf = CONFIG[ENVIRONMENT]
  return dbconf['url'] if dbconf.key?('url')
  uri = "postgres://#{dbconf['username']}"
  uri << ":#{dbconf['password']}" if dbconf['password']
  uri << "@#{dbconf['host']}"
  uri << ":#{dbconf['port']}" if dbconf['port']
  uri << "/#{dbconf['database']}"
end

def schema_version(db)
  db.tables.include?(:schema_info) ? db[:schema_info].first[:version] : 0
end

def build_blank_migration
  "Sequel.migration do\n  up{}\n  down{}\nend"
end

def next_migration_prefix
  mkdir_p(MIGRATION_LOCATION) unless Dir.exist? MIGRATION_LOCATION
  Dir.entries(MIGRATION_LOCATION).sort.last.to_i + 1 || 0
end

CONFIG_FILE = (PROJECT_ROOT + '/config/database.yml').freeze
raise "Config file not found.
Config file must be located at #{CONFIG_FILE}" unless File.exist?(CONFIG_FILE)
CONFIG = YAML.load_file(CONFIG_FILE).freeze
CX_ID = ENV['CX']
DB_CONFIG = YAML.load_file(File.expand_path(File.join(PROJECT_ROOT, 'config', 'database.yml')))
ENVIRONMENT = (ENV['RACK_ENV'] || 'development').freeze
MODE ||= 'development'.freeze
MIGRATION_LOCATION = File.join(PROJECT_ROOT, DB_CONFIG[ENVIRONMENT]['migration_location']).freeze

namespace :pg do
  require 'pg'

  namespace :users do
    desc 'Creates database user defined for environment in config/databse.yml'
    task :create do
      con = PG.connect(dbname: 'postgres')
      begin
        con.exec("CREATE USER #{CONFIG[ENVIRONMENT]['username']} WITH PASSWORD '#{CONFIG[ENVIRONMENT]['password']}'")
      rescue PG::DuplicateObject
        puts "USER #{CONFIG[ENVIRONMENT]['username']} already exists"
      else
        puts "USER #{CONFIG[ENVIRONMENT]['username']} created"
      end
    end

    desc 'Drops the database user defined in config/database.yml'
    task :drop do
      con = PG.connect(dbname: 'postgres')
      begin
        con.exec("DROP USER IF EXISTS #{CONFIG[ENVIRONMENT]['username']}")
      rescue PG::DependentObjectsStillExist => e
        puts e.message
      else
        puts "#{CONFIG[ENVIRONMENT]['username']} dropped from postgres."
      end
    end
  end

  namespace :db do
    desc 'Creates Database'
    task :create do
      con = PG.connect(dbname: 'postgres')
      begin
        con.exec("CREATE DATABASE #{CONFIG[ENVIRONMENT]['database']} WITH OWNER #{CONFIG[ENVIRONMENT]['username']}")
      rescue PG::DuplicateDatabase
        puts "Database #{CONFIG[ENVIRONMENT]['database']} already exists"
      rescue PG::UndefinedObject => e
        puts "#{e.message.chomp} to own DB #{CONFIG[ENVIRONMENT]['database']}"
        puts 'Please run the postgres:users:create task first, and verify it is successful.'
      else
        puts "Database #{CONFIG[ENVIRONMENT]['database']} created."
      end
    end

    desc 'Drops Database'
    task :drop do
      con = PG.connect(dbname: 'postgres')
      con.exec("DROP DATABASE IF EXISTS #{CONFIG[ENVIRONMENT]['database']}")
      puts "Database #{CONFIG[ENVIRONMENT]['database']} dropped."
    end

    desc 'Rebuilds the database'
    task :rebuild do
      %w(pg:db:drop pg:db:create pg:migrations:migrate).each do |cmd|
        Rake::Task[cmd].invoke
      end
    end
  end

  namespace :migrations do
    require 'sequel'

    desc 'Executes all unrun migrations'
    task :migrate do
      Sequel.extension :migration
      DB = Sequel.connect(db_uri)
      Sequel::Migrator.run(DB, MIGRATION_LOCATION)
      Rake::Task['pg:migrations:version'].execute
    end

    desc 'Rollback the specified number of migrations'
    task :rollback, [:count] do |_t, args|
      Sequel.extension :migration
      DB = Sequel.connect(db_uri)
      version = schema_version DB
      args.with_defaults(count: 1)
      Sequel::Migrator.run(DB, MIGRATION_LOCATION, target: (version.to_i - args[:count].to_i))
      Rake::Task['pg:migrations:version'].execute
    end

    desc 'Rollback all migrations'
    task :reset do
      Sequel.extension :migration
      DB = Sequel.connect(db_uri)
      Sequel::Migrator.run(DB, MIGRATION_LOCATION, target: 0)
      Rake::Task['pg:migrations:version'].execute
    end

    desc 'Generates a new database migration file'
    task :generate, [:desc] do |_t, args|
      raise 'Database migration must have a description' if args[:desc].nil?
      file_prefix = format('%03d', next_migration_prefix)
      file = File.new("#{MIGRATION_LOCATION}/#{file_prefix}_#{args[:desc]}.rb", 'w+')
      file.print build_blank_migration
      file.close
    end

    desc 'Prints current schema version'
    task :version do
      version = schema_version DB
      puts "Schema Version: #{version}"
    end
  end
end
