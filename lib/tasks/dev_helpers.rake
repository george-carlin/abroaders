task print_emails_of_onboarded_accounts: :environment do
  # If I need to find a sample user I can log in as
  puts Account.all.select(&:onboarded?).map(&:email)
end
