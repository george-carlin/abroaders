require 'pathname'
APP_ROOT ||= Pathname.new(File.expand_path('../..', __FILE__))

# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!
