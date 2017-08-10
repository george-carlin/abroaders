source 'https://rubygems.org'

ruby '2.4.1'

gem 'rails', '5.0.2'
gem 'trailblazer', '~> 2.0.6'
gem 'trailblazer-rails', '>= 1.0.0'

gem 'cells', '~> 4.1.7'
gem 'cells-erb', '0.0.9'

gem 'acts_as_tree', '~> 2.4.0'
gem 'aws-sdk-v1', '1.61.0'
gem 'browserify-rails', '3.1.0'
gem 'custom_counter_cache'
gem 'cells-rails'
gem 'devise', '~> 4.1.0'
gem 'disposable'
gem 'dry-configurable', '0.3.0'
gem 'dry-struct', '~> 0.2.0'
gem 'dry-types', '~> 0.9.4'
gem 'dry-validation', '0.10.5'
gem 'file_validators'
gem 'httparty', '~> 0.13.7'
gem 'inflecto'
gem 'jquery-rails', '4.1.1'
gem 'kaminari', '~> 1.0.0'
gem 'kaminari-cells', '~> 1.0.0'
gem 'newrelic_rpm', '3.18.1.330'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'paperclip', '4.3.6'
gem 'pg', '0.18.4'
gem 'puma', '~> 3.8.2'
gem 'rack-cors'
gem 'redis', '~> 3.3.3'
gem 'reform'
gem 'reform-rails'
gem 'resque'
gem 'rinku'
gem 'resque-scheduler', '4.2.1'
gem 'sass-rails'
gem 'sinatra', '2.0.0'
gem 'trailblazer-cells'
gem 'uglifier', '3.0.0'
gem 'virtus'
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
  gem 'timecop'
  gem 'poltergeist', '1.9.0'
  gem 'shoulda-matchers', '~> 3.1.1'
  gem 'launchy'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
