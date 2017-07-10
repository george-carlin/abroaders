class TravelPlan < TravelPlan.superclass
  class Onboard < Trailblazer::Operation
    step :assert_account_has_correct_onboarding_state!
    step Nested(Create)
    step :update_onboarding_state!

    private

    def assert_account_has_correct_onboarding_state!(current_account:, **)
      return true if current_account.onboarding_state == 'travel_plan'
      raise 'account must be in "travel_plan" onboarding state'
    end

    def update_onboarding_state!(current_account:, **)
      Account::Onboarder.new(current_account).add_travel_plan!
      true
    end
  end
end
