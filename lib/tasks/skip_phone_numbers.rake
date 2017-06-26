namespace :ab do
  # Sometimes users will sign up and get all the way to the last page of the
  # onboarding survey (phone number), then stop. This is a problem because the
  # phone number is optional anyway, and there's no reason not to consider
  # these people 'onboarded' and move on with sending them recs etc. (Some
  # of them may have actually requested recs as part of the survey.)
  #
  # This task, which runs once a day, obviates this problem by finding anyone
  # who signed up more than 24 hours ago but whose onboarding state is
  # 'phone_number'
  task skip_phone_numbers: :environment do
    Account.where(
      'created_at < (?)', 1.day.ago,
    ).where(
      onboarding_state: 'phone_number',
    ).each do |account|
      PhoneNumber::Skip.(account)
    end
  end
end
