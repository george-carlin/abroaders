# These emails are sent to an email address where they're then detected by
# IfThisThenThat and used to trigger bunch of different APIs, set up by Erik.
# We're doing it this way because it's quicker and easier than writing the Ruby
# to trigger the APIs directly, and it means that Erik can easily tweak the
# IFTTT script without having to use up developer time. Eventually we'll want
# to update things so our app triggers the APIs directly, but it's low
# priority.
class AccountMailer < ApplicationMailer
  class << self
    def method_missing(meth, *args, &block)
      if action_methods.include?(meth) && ENV['DISABLE_ACCOUNT_MAILER']
        require 'dummy_message'

        Rails.logger.info("Not performing #{meth} - AccountMailer is disabled")
        DummyMessage.new
      else
        super
      end
    end
  end

  # The email body contains a field 'Promo Code', but the value will always be
  # blank. This is a legacy thing; we're leaving it in so Erik doesn't have to
  # change the Mailparser endpoint
  def notify_admin_of_sign_up(account_id)
    @account = Account.find(account_id)
    mail(to: ENV['MAILPARSER_NEW_SIGNUP'], subject: "New sign up at Abroaders app - #{@account.email}")
  end

  # `timestamp` is an Unix integer timestamp, not a Date object, because the
  # latter can't be stored in Redis
  def notify_admin_of_survey_completion(account_id, timestamp)
    @account   = Account.find(account_id)
    @owner     = PersonWithStatus.new(@account.owner)
    @companion = PersonWithStatus.new(@account.companion) if @account.companion
    @timestamp = Time.at(timestamp).in_time_zone("EST")
    mail(to: ENV['MAILPARSER_SURVEY_COMPLETE'], subject: "App Profile Complete - #{@account.email}")
  end

  # `timestamp` is an Unix integer timestamp, not a Date object, because the
  # latter can't be stored in Redis.
  #
  # This is triggered whenever anyone makes a new recommendation request
  # anywhere after the onboarding survey. It's called a 'readiness update' for
  # legacy reasons.
  def notify_admin_of_user_readiness_update(account_id, timestamp)
    @account   = Account.find(account_id)
    @owner     = PersonWithStatus.new(@account.owner)
    @companion = PersonWithStatus.new(@account.companion) if @account.companion
    @timestamp = Time.at(timestamp).in_time_zone("EST")
    mail(to: ENV['MAILPARSER_USER_READY'], subject: "User is Ready - #{@account.email}")
  end

  # For legacy reasons, we still use the language 'Ready' here even though we
  # now call it a recommendation request elsewhere in the app. This is so Erik
  # doesn't have to update the IFTTT endpoints.
  #
  # `#status` was originally a method on the Person class itself, but since
  # it's not being used anywhere except in these legacy emails, extract it to a
  # decorator here.
  class PersonWithStatus < SimpleDelegator
    def status
      if ineligible?
        'Ineligible'
      elsif unresolved_recommendation_request?
        'Ready'
      else
        'Eligible(NotReady)'
      end
    end
  end
end
