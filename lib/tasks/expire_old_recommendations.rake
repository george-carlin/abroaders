namespace :abr do
  task expire_old_recommendations: :environment do
    count = CardAccount.expire_old_recommendations!

    puts "expired #{count} recommendation#{'s' unless count == 1}"
  end
end
