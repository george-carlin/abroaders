source 'https://rubygems.org'

ruby '2.4.1'

gem 'rails', '5.0.2'
gem 'trailblazer', '~> 2.0.1'
gem 'trailblazer-rails', '>= 1.0.0'

# Using my own fork of cells which has a change to how Collection#join works.
# My PR has been merged but not released, see https://github.com/trailblazer/cells/pull/448
# Once it's released we can switch back to getting cells from Rubygems
gem 'cells', github: 'georgemillo/cells', branch: 'collection-join'
gem 'cells-erb', '0.0.9'

gem 'acts_as_tree', '~> 2.4.0'
gem 'aws-sdk-v1', '1.61.0'
gem 'browserify-rails', '3.1.0'
gem 'cells-rails'
gem 'devise', '~> 4.1.0'
gem 'devise-bootstrap-views', '0.0.8'
gem 'disposable'
gem 'dry-configurable', '0.3.0'
gem 'dry-struct'
gem 'dry-types', '~> 0.9.4'
gem 'dry-validation', '0.10.5'
gem 'figaro', '~> 1.1.1'
gem 'font-awesome-rails', '4.6.3.0'
gem 'httparty', '~> 0.13.7'
gem 'intercom', '3.5.10'
gem 'inflecto'
gem 'jquery-rails', '4.1.1'
# kaminari-cells 0.0.4 (which is the highest version atm) isn't compatible with
# kaminari 1+, so lock the version at 0.17. See kaminari-cells #6 on GitHub.
gem 'kaminari', '0.17.0'
gem 'kaminari-cells', '0.0.4'
gem 'newrelic_rpm', '3.18.1.330'
gem 'paperclip', '4.3.6'
gem 'pg', '0.18.4'
gem 'puma', '~> 3.8.2'
gem 'redis', '~> 3.3.3'
gem 'reform'
gem 'reform-rails'
gem 'resque'
gem 'resque-scheduler', '4.2.1'
gem 'sass-rails'
gem 'simple_form', '3.3.1'
# We need to use edge Sinatra from Github as it's dependent on Rack 2+ (like
# Rails 5) and that's the only way to make Resque::Server work.
gem 'sinatra', github: 'sinatra/sinatra', branch: 'master'
gem 'trailblazer-cells'
gem 'uglifier', '3.0.0'
gem 'virtus'
gem 'will_paginate-bootstrap', '~> 1.0.1'
gem 'rails_autolink'
gem 'workflow'

# we don't depend on dry-logic directly, but other dry-* dependencies need it,
# and versions <= 0.4.0 raise warnings on Ruby 2.4 (because of Fixnum)
gem 'dry-logic', '~> 0.4.1'

group :development, :test do
  gem 'bullet', '5.3.0'
  gem 'byebug'
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'faker', '1.7.2'
  # mutant depends on unparser, which in turn depends on diff-lcs. diff-lcs
  # v1.2.5 raises warnings on Ruby 2.4.0, while v1.3 should remove these
  # warnings, but unfortunately the latest version of unparser depends on
  # diff-lcs ~>1.2.5, so we can't upgrade to 1.3 for now and we'll just have to
  # live with the warnings
  gem 'mutant-rspec'
  gem 'rspec-rails', '~> 3.5.0'
  gem 'rspec-cells'
  gem 'guard-rspec', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.0'
  gem 'binding_of_caller'
  # Restrict the version of rubocop so that our build doesn't break because our
  # code no longer passes on a newer version of rubocop
  gem 'rubocop', '~> 0.43.0', require: false
end

group :test do
  gem 'capybara', '2.7.1'
  gem 'nokogiri', '1.7.0.1'
  # Similarly, lock addressable (another dependency of capybara)
  gem 'addressable', '2.4.0'
  gem 'poltergeist', '1.9.0'
  gem 'shoulda-matchers', '~> 3.1.1'
  gem 'launchy'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
