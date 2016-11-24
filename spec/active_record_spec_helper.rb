# A spec helper that only loads what's absolutely necessary to test
# ActiveRecord classes. Loaded automatically by rails_helper, but can (in
# theory) be used by itself for faster tests.
#
# Inspired by http://articles.coreyhaines.com/posts/active-record-spec-helper/
require 'spec_helper'

require 'yaml'
require 'database_cleaner'

require 'active_record'

require_relative './support/test_data_store'

connection_info = YAML.load_file('config/database.yml')['test']
ActiveRecord::Base.establish_connection(connection_info)

RSpec.configure do |config|
  # For info on how the 'manual_clean' option works, see the notes in
  # spec/support/test_data_store.rb
  config.around(:each) do |example|
    if example.metadata[:js]
      if example.metadata[:manual_clean]
        ApplicationRecord.__storing_on = true
        example.run
        TestDataStore.clean
        ApplicationRecord.__storing_on = false
      else
        DatabaseCleaner.strategy = :truncation
        DatabaseCleaner.start
        example.run
        DatabaseCleaner.clean
      end
    else
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
      example.run
      DatabaseCleaner.clean
    end
  end

  config.after(:all) do
    DatabaseCleaner.clean_with :truncation
  end
end
