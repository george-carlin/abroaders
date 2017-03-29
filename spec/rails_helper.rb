# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require_relative 'spec_helper'
require_relative 'active_record_spec_helper'
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
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    url_whitelist: ['http://example.com'],
  )
end
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
  config.include AlertsMacros, type: :feature
  config.include DatepickerMacros, type: :feature
  config.include TitleHelper, type: :feature
  config.include TypeaheadMacros, type: :feature
  config.include WaitForAjax, type: :feature

  config.after(:each) do
    Warden.test_reset!
  end

  def login_as_account(account)
    login_as account, scope: :account
  end

  def login_as_admin(admin)
    login_as admin, scope: :admin
  end

  def fill_in_autocomplete(field, with)
    fill_in field, with: with

    page.execute_script("$('##{field}').trigger('focus');")
    page.execute_script "$('##{field}').trigger('keydown');"
    selector = ".tt-menu .tt-dataset div.tt-suggestion"
    page.execute_script("$(\"#{selector}\").mouseenter().click()")
  end

  JQUERY_DEFAULT_SLIDE_DURATION = 0.4
  # Some elements on the page are hidden/shown using jQuery's 'slide' methods,
  # which by default take 400ms to complete. So use this method to wait
  # for a slideUp/slideDown to finish:
  def wait_for_slide
    sleep JQUERY_DEFAULT_SLIDE_DURATION
  end

  def send_all_enqueued_emails!
    enqueued_jobs.select { |job| job[:job] == ActionMailer::DeliveryJob }.each do |job|
      ActionMailer::DeliveryJob.perform_now(*job[:args])
    end
  end

  # A replacement for FactoryGirl that exclusively creates and updates data
  # using our own operations, and therefore creates data in the exact same way
  # a user would. Ideally all test data should be created in this way and we
  # would do away with FactoryGirl altogether. This method is long and ugly but
  # it's a start; ideally we'd have some kind of unified interface similar
  # to FactoryGirl's "create" method that delegates to methods like the one
  # below
  #
  # This method has an interface like FactoryGirl's, in that you can pass both
  # traits (an array of symbols; you don't have to pass any traits) and a hash
  # of attributes. Attributes will be passed to the 'Create' operation,
  # although defaults will be provided if you miss any out. Valid traits are
  # ':verified', which means an admin will verify the offer after creating it,
  # and ':dead', which means an admin will kill the offer after creating it.
  #
  # To get an unknown offer, create a card product and call its #unknown_offer
  # method.
  def create_offer(*traits_and_overrides)
    overrides = if traits_and_overrides.last.is_a?(Hash)
                  traits_and_overrides.pop
                else
                  {}
                end

    if overrides.keys.include?(:last_reviewed_at)
      raise 'invalid key :last_reviewed_at, pass :verified as a trait'
    end
    if overrides.keys.include?(:killed_at)
      raise 'invalid key :killed_at, pass :dead as a trait'
    end

    attrs = { # defaults
      condition: 'on_minimum_spend',
      cost: rand(20) * 5,
      days: [30, 60, 90, 90, 90, 90, 90, 90, 120].sample,
      link: Faker::Internet.url('example.com'),
      partner: 'card_benefit',
      points_awarded: rand(20) * 5_000,
      spend: rand(10) * 500,
    }

    product_id = overrides.fetch(:product, create(:product)).id

    offer = run!(
      AdminArea::Offers::Operation::Create,
      offer: attrs,
      card_product_id: product_id,
    )['model']

    traits = traits_and_overrides
    if traits.include?(:verified)
      result = AdminArea::Offers::Operation::Verify.(id: offer.id)
      raise unless result.success?
      offer = result['model']
    end
    if traits.include?(:dead)
      result = AdminArea::Offers::Operation::Kill.(id: offer.id)
      raise unless result.success?
      offer = result['model']
    end

    offer
  end

  def create_card_recommendation(*traits_and_overrides)
    overrides = if traits_and_overrides.last.is_a?(Hash)
                  traits_and_overrides.pop
                else
                  {}
                end

    raise "don't use :offer as a key, pass :offer_id" if overrides.key?(:offer)
    raise "don't use :person as a key, pass :person" if overrides.key?(:person)

    offer_id  = overrides.fetch(:offer_id, create_offer.id)
    person_id = overrides.fetch(:person_id, create(:person).id)

    rec = run!(
      AdminArea::CardRecommendations::Operation::Create,
      card_recommendation: { offer_id: offer_id }, person_id: person_id,
    )['model']

    traits = traits_and_overrides

    # TODO extract ops for these actions
    rec.applied_on = 4.days.ago if traits.include?(:applied)

    if traits.include?(:approved)
      rec.applied_on = 4.days.ago
      rec.opened_on  = Date.today
    end

    if traits.include?(:called)
      rec.applied_on = 4.days.ago
      rec.denied_at  = 3.days.ago
      rec.called_at  = Time.zone.now
    end

    rec.expired_at = Time.zone.now if traits.include?(:expired)

    if traits.include?(:nudged)
      rec.applied_on = 4.days.ago
      rec.nudged_at = Time.zone.now
    end

    rec.pulled_at = Time.zone.now if traits.include?(:pulled)

    if traits.include?(:denied)
      rec.applied_on = 4.days.ago
      rec.denied_at  = 3.days.ago
    end

    if traits.include?(:redenied)
      rec.applied_on = 4.days.ago
      rec.denied_at  = 3.days.ago
      rec.called_at  = Time.zone.now
      rec.redenied_at = Time.zone.now
    end

    rec.save!
    rec
  end
end
