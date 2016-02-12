namespace :ab do
  namespace :sample_data do
    task setup: :environment do
      include FactoryGirl::Syntax::Methods
    end

    task all: [:users, :travel_plans]

    task users: :setup do
      ApplicationRecord.transaction do
        if User.non_admin.any? && !ENV["CONFIRM_SAMPLE_DATA"]
          puts "There are already users in the database. Are you sure you want"\
               "to add sample users? Please run the task again with "\
               "CONFIRM_SAMPLE_DATA set to true to continue"
          next
        end

        count = 50
        count.times do
          date = ((500).days + rand(24).hours + rand(60).minutes).ago
          args = [:user, { created_at: date, confirmed_at: date } ]
          args.insert(1, :survey_complete) if rand > 0.2
          user = build(*args)

          if user.survey.present?
            user.survey.assign_attributes(
              middle_names: (Faker::Name.first_name if rand > 0.1),
              whatsapp: rand > 0.4,
              text_message: rand > 0.1,
              imessage: rand > 0.7,
            )
          end

          user.save!
        end

        puts "Created #{count} sample users"
      end # transaction
    end # :users

    task travel_plans: :setup do
      count_before = TravelPlan.count

      ApplicationRecord.transaction do
        if User.onboarded.none?
          puts "Can't add travel plans; no onboarded users in the database to "\
               "add them to"
          next
        end

        User.onboarded.find_each do |user|
          next if user.travel_plans.any?

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
            create(:travel_plan, type, user: user)
          end
        end

      end # transaction

      puts "created #{TravelPlan.count - count_before} new travel plans"
    end # :travel_plan
  end
end
