namespace :ab do
  namespace :sample_data do
    task setup: :environment do
      include FactoryGirl::Syntax::Methods
    end

    task all: [:accounts, :travel_plans]

    task accounts: :setup do
      ApplicationRecord.transaction do
        if Account.any? && !ENV["CONFIRM_SAMPLE_DATA"]
          puts "There are already accounts in the database. Are you sure "\
               "you want to add sample accounts? Please run the task again "\
               "with CONFIRM_SAMPLE_DATA set to true to continue"
          next
        end

        (no_of_accounts = 50).times do
          random = rand()
          # Create a sample of accounts in different stages of the onboarding
          # process:
          account = if random > 0.95
                      create(:account)
                    elsif random > 0.85
                      create(:account, :passenger)
                    elsif random > 0.8
                      create(:account, :companion)
                    elsif random > 0.7
                      create(:account, :passenger, :spending)
                    elsif random > 0.3
                      create(:onboarded_account)
                    else
                      create(:onboarded_companion_account)
                    end

          # Make the main passenger's first name match the account's email
          # address:
          if account.main_passenger
            account.main_passenger.first_name = \
              account.email.split("@").first.sub(/-\d+/, "").capitalize
          end

          date = ((500).days + rand(24).hours + rand(60).minutes).ago
          account.created_at = date

          account.save!
        end

        puts "Created #{no_of_accounts} sample accounts"
      end # transaction
    end # :account

    task travel_plans: :setup do
      count_before = TravelPlan.count

      ApplicationRecord.transaction do
        if Account.onboarded.none?
          puts "Can't add travel plans; no onboarded account in the database "\
               "to add them to"
          next
        end

        unless Destination.any?
          puts "Can't add travel plans; no destinations in the database "
          next
        end

        Account.onboarded.find_each do |account|
          next if account.travel_plans.any?

          rand(4).times do
            # Most travel plans will be 'return', and few will be 'multi',
            # so weight the sample data accordingly
            roll = rand(10)
            type =  if roll > 0.4
                      :return
                    elsif roll > 0.1
                      :single
                    else
                      :multi
                    end
            create(:travel_plan, type, account: account)
          end
        end

      end # transaction

      puts "created #{TravelPlan.count - count_before} new travel plans"
    end # :travel_plan
  end
end
