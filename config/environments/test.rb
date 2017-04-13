Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=3600',
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Randomize the order test cases are executed.
  config.active_support.test_order = :random

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  config.action_view.raise_on_missing_translations = true

  config.action_mailer.default_url_options = { host: 'localhost:3000' }

  config.log_level = :error

  config.active_job.queue_adapter = :test

  config.after_initialize do
    Bullet.enable = !!ENV['BULLET']
    Bullet.bullet_logger = true
    Bullet.raise = true # raise an error if n+1 query occurs

    # Detect eager-loaded associations which are not used
    #
    # Note that if you enable this setting, you'll get some test failures where
    # the eager-loaded association *is* used, it's just not used during one
    # particular test. Bullet has no way of knowing this, so it raises the
    # error/warning anyway. (One example of this is the cards#index action - if
    # you view the page when the account has no card accounts and/or
    # recommendations, you'll get the 'unused eager-load' warning. But if you
    # view the page when they DO have accounts/recs, there's no warning.)
    #
    # There's no way we can avoid this really, unless we refactor actions like
    # card_accounts#index so they use the associations no matter what - but
    # even that would be rather pointless since it's not a big issue that
    # assocations are being eager-'loaded' when the assoc is actually empty.
    #
    # So if you see a warning from Bullet about an unused eager-load, make sure
    # that it's *truly* unused before you remove it.
    Bullet.unused_eager_loading_enable = false
    # Detect unnecessary COUNT queries which could be avoided
    # with a counter_cache
    Bullet.counter_cache_enable        = false
  end
end
