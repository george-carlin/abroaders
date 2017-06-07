namespace :ab do
  desc "A notification email to remind a user about the annual fee"
  task annual_fee_reminder_email: :environment do
    CardAccount::SendAnnualFeeReminder.()
  end
end
