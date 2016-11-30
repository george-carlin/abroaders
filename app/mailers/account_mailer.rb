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
    mail(to: ENV['MAILPARSER_NEW_SIGNUP'], subject: "New sign up at Abroaders app - #{@account.email}")
  end

  # `timestamp` is an Unix integer timestamp, not a Date object, because the
  # latter can't be stored in Redis
  def notify_admin_of_survey_completion(account_id, timestamp)
    @account = Account.find(account_id)
    @timestamp = Time.at(timestamp).in_time_zone("EST")
    mail(to: ENV['MAILPARSER_SURVEY_COMPLETE'], subject: "App Profile Complete - #{@account.email}")
  end

  # `timestamp` is an Unix integer timestamp, not a Date object, because the
  # latter can't be stored in Redis.
  #
  # This is triggered when a person who is NOT ready updates their status to
  # ready. It's NOT triggered when a new person says on the onboarding survey
  # that they are ready.
  def notify_admin_of_user_readiness_update(account_id, timestamp)
    @account   = Account.find(account_id)
    @owner     = @account.owner
    @companion = @account.companion
    @timestamp = Time.at(timestamp).in_time_zone("EST")
    mail(to: ENV['MAILPARSER_USER_READY'], subject: "User is Ready - #{@account.email}")
  end
end
