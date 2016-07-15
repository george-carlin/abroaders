# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require_relative 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

include Warden::Test::Helpers
Warden.test_mode!

require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.include ActionView::RecordIdentifier, type: :feature
  config.include ActiveJob::TestHelper
  config.include ControllerMacros, type: :controller
  config.include Devise::TestHelpers, type: :controller
  config.include FactoryGirl::Syntax::Methods
  config.include I18nWithErrorRaising
  config.include WaitForAjax, type: :feature
  config.include AlertsMacros, type: :feature
  config.include TitleHelper, type: :feature

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

  config.after(:each) do
    Warden.test_reset!
  end

  config.after(:all) do
    DatabaseCleaner.clean_with :truncation
  end

  def login_as_account(account)
    login_as account, scope: :account
  end

  def login_as_admin(admin)
    login_as admin, scope: :admin
  end

  JQUERY_DEFAULT_SLIDE_DURATION = 0.4
  # Some elements on the page are hidden/shown using jQuery's 'slide' methods,
  # which by default take 400ms to complete. So use this method to wait
  # for a slideUp/slideDown to finish:
  def wait_for_slide
    sleep JQUERY_DEFAULT_SLIDE_DURATION
  end

  def send_all_enqueued_emails!
    enqueued_jobs.select{ |job| job[:job] == ActionMailer::DeliveryJob }.each do |job|
      ActionMailer::DeliveryJob.perform_now(*job[:args])
    end
  end

end
