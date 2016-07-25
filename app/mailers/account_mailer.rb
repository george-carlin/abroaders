class AccountMailer < ApplicationMailer

  def notify_admin_of_sign_up(account_id)
    @account = Account.find(account_id)
    mail(to: ENV["ERIKS_EMAIL"], subject: "New sign up at Abroaders app - #{@account.email}")
  end

  def notify_admin_of_survey_completion(account_id, timestamp_string)
    #timestamp_string because ActiveJob cannot accept Time arguments
    @account = Account.find(account_id)
    @timestamp = timestamp_string
    mail(to: ENV["ERIKS_EMAIL"], subject: "App Profile Complete - #{@account.email}")
  end

end
