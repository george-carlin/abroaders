class TravelPlan < TravelPlan.superclass
  module Operation
    class Onboard < Trailblazer::Operation
      step :assert_account_has_correct_onboarding_state!
      step Nested(Operation::Create)
      step :update_onboarding_state!

      private

      def assert_account_has_correct_onboarding_state!(_opts, account:, **)
        return true if account.onboarding_state == 'travel_plan'
        raise 'account must be in "travel_plan" onboarding state'
      end

      def update_onboarding_state!(_opts, account:, **)
        Account::Onboarder.new(account).add_travel_plan!
        true
      end
    end
  end
end
