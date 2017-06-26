module PhoneNumber
  class Skip
    def self.call(account)
      Account::Onboarder.new(account).skip_phone_number!
      # rubocop:disable Lint/HandleExceptions
    rescue Workflow::NoTransitionAllowed
      # Noop. This may happen in the unlikely event that someone still has the
      # phone number survey page open 24 hours after signing up.  The
      # skip_phone_numbers task will run and update their onboarding_state, but
      # they'll still be able to submit the form and potentially cause a crash.
    end
    # rubocop:enable Lint/HandleExceptions
  end
end
