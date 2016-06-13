ENVIRONMENT = (ENV['RACK_ENV'] || 'development').freeze
PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze
$LOAD_PATH.unshift(File.expand_path(File.join(PROJECT_ROOT, 'config')))
require 'environment'
$LOAD_PATH.unshift(File.expand_path(File.join(PROJECT_ROOT, 'application', 'models')))
require 'planter'

farmer = Planter.new(ENVIRONMENT)
farmer.plant
