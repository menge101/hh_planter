Dir.glob('lib/tasks/*.rake').each { |r| import r }

require 'rspec/core'
require 'rspec/core/rake_task'

PROJECT_ROOT = File.expand_path(File.dirname(__FILE__)).freeze

RSpec::Core::RakeTask.new(:spec)
