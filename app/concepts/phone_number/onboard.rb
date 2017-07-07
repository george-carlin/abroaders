require_dependency 'reform/form/dry'

module PhoneNumber
  # Add a phone number to the current_account as part of the onboarding survey
  class Onboard < Trailblazer::Operation
    step :in_correct_onboarding_state?
    failure :log_invalid_onboarding_state
    step Wrap(Abroaders::Transaction) {
      step Nested(PhoneNumber::Create)
      step :update_onboarding_state!
      failure :rollback
    }

    private

    def in_correct_onboarding_state?(current_account:, **)
      current_account.onboarding_state == 'phone_number'
    end

    def log_invalid_onboarding_state(opts)
      opts['errors'] = 'current_account in invalid onboarding state'
    end

    def update_onboarding_state!(current_account:, **)
      Account::Onboarder.new(current_account).add_phone_number!
    end

    def rollback(*)
      raise ActiveRecord::Rollback
    end
  end
end
