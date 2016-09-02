# These emails are sent to an email address where they're then detected by
# IfThisThenThat and used to trigger bunch of different APIs, set up by Erik.
# We're doing it this way because it's quicker and easier than writing the Ruby
# to trigger the APIs directly, and it means that Erik can easily tweak the
# IFTTT script without having to use up developer time. Eventually we'll want
# to update things so our app triggers the APIs directly, but it's low
# priority.
class AccountMailer < ApplicationMailer

  def notify_admin_of_sign_up(account_id)
    @account = Account.find(account_id)
    mail(to: ENV["ADMIN_EMAIL"], subject: "New sign up at Abroaders app - #{@account.email}")
  end

  def notify_admin_of_survey_completion(account_id, timestamp)
    @account = Account.find(account_id)
    @timestamp = Time.at(timestamp).in_time_zone("EST")
    mail(to: ENV["ADMIN_EMAIL"], subject: "App Profile Complete - #{@account.email}")
  end

end
