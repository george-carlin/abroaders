namespace :abr do
  task expire_old_recommendations: :environment do
    CardRecommendation::Operation::ExpireOld.()
  end
end
