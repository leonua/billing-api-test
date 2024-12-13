ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  RSpec.configure do |config|
    config.include FactoryBot::Syntax::Methods

    DatabaseCleaner.strategy = :truncation
    config.around(:each) do |example|
      DatabaseCleaner.cleaning do
         example.run
      end
    end

    config.before(:all) do
      DatabaseCleaner.start
    end

    config.after(:all) do
      DatabaseCleaner.clean
    end
  end
end
