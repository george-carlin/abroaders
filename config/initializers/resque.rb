Resque.redis = Rails.env.production? ? ENV["REDIS_URL"] : 'localhost:6379'
Resque.after_fork = proc { ActiveRecord::Base.establish_connection }
