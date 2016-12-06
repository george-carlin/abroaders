source 'https://rubygems.org'

ruby '2.3.0'

gem 'rails', '~> 5.0.0.1'
gem 'trailblazer-rails'
gem 'trailblazer', '~> 1.1.2'

gem 'active_model_serializers', '~> 0.10.0'
gem 'acts_as_tree', '~> 2.4.0'
gem 'aws-sdk', '1.61.0'
gem 'bitmask_attributes'
gem 'browserify-rails'
gem 'cells-erb'
gem 'cells-rails'
gem 'devise', '~> 4.1.0'
gem 'devise-bootstrap-views'
gem 'dry-configurable'
gem 'dry-validation'
# Load ENV variables from a gitignored YAML file
gem 'figaro', '~> 1.1.1'
gem 'font-awesome-rails'
gem 'httparty', '~> 0.13.7'
gem 'intercom'
gem 'inflecto'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'kaminari-cells'
gem 'newrelic_rpm'
gem 'paperclip', '~> 4.3.1'
gem 'pg', '~> 0.18'
gem 'puma'
gem 'record_tag_helper'
gem 'reform-rails'
gem 'resque'
gem 'resque-scheduler'
gem 'sass-rails'
gem 'simple_form'
# We need to use edge Sinatra from Github as it's dependent on Rack 2+ (like
# Rails 5) and that's the only way to make Resque::Server work.
gem 'sinatra', github: 'sinatra/sinatra', branch: 'master'
gem 'trailblazer-cells'
gem 'uglifier', '>= 1.3.0'
gem 'virtus'
gem 'will_paginate-bootstrap', '~> 1.0.1'
gem 'rails_autolink'
gem 'workflow'

group :production do
  # Required to make the app function properly on Heroku:
  gem 'rails_12factor'
end

group :development, :test do
  gem 'byebug'
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'faker'
  gem 'rspec-rails', '~> 3.5.0'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.0'
  gem 'bullet'
  gem 'binding_of_caller'
  # Restrict the version of rubocop so that our build doesn't break because our
  # code no longer passes on a newer version of rubocop
  gem 'rubocop', '~> 0.43.0', require: false
end

group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'shoulda-matchers', '~> 3.1.1'
  gem 'launchy'
  gem 'vcr'
  gem 'webmock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
