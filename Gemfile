source 'https://rubygems.org'

ruby '2.3.0'

# Use master branch of rails for now because rails_12factor has a bug with
# rails 5.0.0.beta1. See http://stackoverflow.com/a/34578109/1603071 and
# https://github.com/rails/rails/pull/22933
gem 'rails', '>= 5.0.0.beta1', '< 5.1'

gem 'pg', '~> 0.18'
gem 'uglifier', '>= 1.3.0'

gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'puma'

gem 'devise', github: 'plataformatec/devise'
gem 'devise-bootstrap-views'

gem 'active_model_serializers', '~> 0.10.0.rc3'

gem 'sass-rails'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Load ENV variables from a gitignored YAML file
gem 'figaro', '~> 1.1.1'

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
  gem 'rspec-rails'
  gem 'quiet_assets'
  gem 'database_cleaner'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.0'
end

group :test do
  gem 'capybara', github: 'jnicklas/capybara'
  gem 'poltergeist'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
