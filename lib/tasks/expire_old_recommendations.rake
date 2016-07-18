namespace :abr do
  task expire_old_recommendations: :environment do
    CardAccount.expire_old_recommendations!
  end
end
