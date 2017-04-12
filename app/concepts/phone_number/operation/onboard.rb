require_dependency 'reform/form/dry'

class PhoneNumber < PhoneNumber.superclass
  module Operation
    # Add a phone number to the account as part of the onboarding
    # survey
    class Onboard < Trailblazer::Operation
      step :validate_account_onboarding_state!
      failure :log_invalid_onboarding_state!
      step Wrap(Abroaders::Transaction) {
        step Nested(PhoneNumber::Operation::Create)
        step :update_onboarding_state!
      }

      private

      def update_onboarding_state!(options)
        Account::Onboarder.new(options['account']).add_phone_number!
      end

      def validate_account_onboarding_state!(options)
        options['account'].onboarding_state == 'phone_number'
      end

      def log_invalid_onboarding_state!(_options)
        result['errors'] = 'account in invalid onboarding state'
      end
    end
  end
end
