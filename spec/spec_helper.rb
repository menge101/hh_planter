ENVIRONMENT = (ENV['RACK_ENV'] || 'test').freeze
PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze
$LOAD_PATH.unshift(File.expand_path(File.join(PROJECT_ROOT, 'config')))
require 'environment'
Dir.glob(File.expand_path(File.join(PROJECT_ROOT, 'application', '**/*.rb'))).each { |f| require f }

require 'database_cleaner'
require 'factory_girl'
require 'fakeweb'
require 'timecop'
require 'yaml'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  FactoryGirl.find_definitions
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation) if ENVIRONMENT == 'test'
    FakeWeb.allow_net_connect = false
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
