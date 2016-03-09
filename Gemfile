source 'https://rubygems.org'

ruby '2.3.0'

gem 'rails', '>= 5.0.0.beta3', '< 5.1'

gem 'font-awesome-rails'
gem 'active_model_serializers', '~> 0.10.0.rc3'
gem 'acts_as_tree', '~> 2.4.0'
gem 'devise', github: 'plataformatec/devise'
gem 'devise-bootstrap-views'
# Load ENV variables from a gitignored YAML file
gem 'figaro', '~> 1.1.1'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'pg', '~> 0.18'
gem 'puma'
gem 'sass-rails'
gem 'searchlight'
gem 'uglifier', '>= 1.3.0'
gem 'will_paginate-bootstrap', '~> 1.0.1'

gem 'babel-transpiler', '>=0.7.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'browserify-rails'

# Required to make the app function properly on Heroku:
group :production do
  gem 'rails_12factor'
end

# Including these in the production group for now so we can run the seeds file
# on Heroku. Once we've launched the MVP, move these to development/test only:
gem 'factory_girl_rails', '~> 4.5.0'
gem 'faker'

group :development, :test do
  gem 'byebug'
  gem 'database_cleaner'
  gem 'guard-rspec', require: false
  # Quiet assets is completely broken with Rails 5, see
  # https://github.com/evrone/quiet_assets/issues/47
  # gem 'quiet_assets', github: "evrone/quiet_assets", ref: "a39a74c4cefd"
  # gem 'rspec-rails', '>= 3.3.0'
  gem 'rspec-rails', github: "georgemillo/rspec-rails", branch: "rails5"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.0'
end

group :test do
  gem 'capybara', github: 'jnicklas/capybara'
  gem 'poltergeist'
  gem 'shoulda-matchers', '~> 3.1.1'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
