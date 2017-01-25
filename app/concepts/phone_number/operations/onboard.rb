require_dependency 'reform/form/dry'

class PhoneNumber < ApplicationRecord
  module Operations
    # Add a phone number to the current account as part of the onboarding
    # survey
    class Onboard < Trailblazer::Operation
      step :validate_account_onboarding_state!
      failure :log_invalid_onboarding_state!
      # Wrapping the steps in a transaction seems to always return true? FIXME
      # step Wrap ->(*, &block) { ApplicationRecord.transaction { block.call } } {
      step Nested(PhoneNumber::Operations::Create)
      step :update_onboarding_state!
      # }

      private

      def update_onboarding_state!(options)
        Account::Onboarder.new(options['current_account']).add_phone_number!
      end

      def validate_account_onboarding_state!(options)
        options['current_account'].onboarding_state == 'phone_number'
      end

      def log_invalid_onboarding_state!(_options)
        result['errors'] = 'account in invalid onboarding state'
      end
    end
  end
end