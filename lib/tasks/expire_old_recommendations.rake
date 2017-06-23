namespace :abr do
  task expire_old_recommendations: :environment do
    AdminArea::CardRecommendations::ExpireOld.()
  end
end
