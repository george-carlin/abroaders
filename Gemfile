source 'https://rubygems.org'

ruby '2.3.0'

gem 'rails', '~> 5.0.0.1'

gem 'active_model_serializers', '~> 0.10.0'
gem 'acts_as_tree', '~> 2.4.0'
gem 'aws-sdk', '1.61.0'
gem 'bitmask_attributes'
gem 'browserify-rails'
gem 'devise', '~> 4.1.0'
gem 'devise_invitable', '~> 1.7.0'
gem 'devise-bootstrap-views'
# Load ENV variables from a gitignored YAML file
gem 'figaro', '~> 1.1.1'
gem 'font-awesome-rails'
gem 'httparty', '~> 0.13.7'
gem 'intercom'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'paperclip', '~> 4.3.1'
gem 'pg', '~> 0.18'
gem 'puma'
gem 'record_tag_helper'
gem 'resque'
gem 'resque-scheduler'
gem 'sass-rails'
# We need to use edge Sinatra from Github as it's dependent on Rack 2+ (like
# Rails 5) and that's the only way to make Resque::Server work.
gem 'sinatra', github: 'sinatra/sinatra', branch: 'master'
gem 'uglifier', '>= 1.3.0'
gem 'virtus'
gem 'will_paginate-bootstrap', '~> 1.0.1'

# Required to make the app function properly on Heroku:
group :production do
  gem 'rails_12factor'
end

group :development, :test do
  gem 'byebug'
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'faker'
  gem 'rspec-rails', '3.5.0.beta4'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.0'
  gem 'bullet'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rubocop', require: false
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
