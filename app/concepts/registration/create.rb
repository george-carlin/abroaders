module Registration
  class Create < Trailblazer::Operation
    step Nested(New)
    step Contract::Validate(key: :account)
    step :persist_model!
    success :notify_admin!

    private

    def persist_model!(opts, **)
      contract = opts['contract.default']
      contract.sync
      contract.model.test = TEST_EMAILS.any? { |r| r =~ contract.email.downcase }
      contract.model.save
    end

    def notify_admin!(model:, **)
      if ENV['SEND_ADMIN_SIGN_UP_NOTIFICATION_EMAIL']
        AccountMailer.notify_admin_of_sign_up(model.id).deliver_later
      end
    end

    # if the email address matches any of these regexes, set the 'test'
    # boolean flag on the account to TRUE, so that we can filter out these
    # fake accounts from our analytics:
    TEST_EMAILS = [
      /@abroaders.com/i,
      /@example.com/i,
      /\+test/i,
      /georgejulianmillo/i,
      # Note from convo w/ Erik 30/6/17: erik also has an account in production
      # with erik@beingbadass.com, but that includes his real cards, balances
      # etc. and he doesn't want it to be filtered out from stats.
      /paquet2386.*@gmail.com/i,
    ].freeze
  end
end
