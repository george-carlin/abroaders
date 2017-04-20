class Person < Person.superclass
  # Used by the page on the onboarding survey asks the user if they're eligible
  # to apply for cards in the U.S.. (If they have a couples account, it'll ask
  # whether one, both, or neither of the people are eligible.)
  class EligibilitySurvey < Trailblazer::Operation
    step Wrap(Abroaders::Transaction) {
      success :update_eligibility
      success :update_onboarding_state
    }

    private

    def update_eligibility(account:, params:, **)
      case params.fetch(:eligibility_survey).fetch(:eligible)
      when "both"
        account.owner.update_attributes!(eligible: true)
        account.companion.update_attributes!(eligible: true)
      when "owner"
        account.owner.update_attributes!(eligible: true)
      when "companion"
        account.companion.update_attributes!(eligible: true)
      when "neither" # noop
      end
    end

    def update_onboarding_state(account:, **)
      Account::Onboarder.new(account).add_eligibility!
    end
  end
end
