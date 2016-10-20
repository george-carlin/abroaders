# Defines the routes via which the user can move through the onboarding survey.
#
# Example usage:
#
#     flow = OnboardingFlow.build(account)
#     flow.add_home_airports!
#
# `flow.add_home_airports!` will return the new state after adding home
# airports - or it will raise an error if home airports can not be added given
# the current state.
class OnboardingFlow
  include Virtus.model
  include Workflow

  attribute :account, Account
  # 'workflow_state' is the default attribute name used by the workflow gem
  attribute :workflow_state
  delegate :owner, :companion, to: :account

  def self.build(account)
    new(
      account:        account,
      workflow_state: account.onboarding_state,
    )
  end

  workflow do
    state :home_airports do
      event :add_home_airports, transition_to: :travel_plan
    end

    state :travel_plan do
      event :add_travel_plan,  transition_to: :account_type
      event :skip_travel_plan, transition_to: :regions_of_interest
    end

    state :regions_of_interest do
      event :add_regions_of_interest, transition_to: :account_type
    end

    state :account_type do
      event :choose_account_type, transition_to: :eligibility
    end

    state :eligibility do
      event :add_eligibility, transition_to: :owner_cards,
            if: -> (of) { of.owner.eligible? }
      event :add_eligibility, transition_to: :owner_balances
    end

    state :owner_cards do
      event :add_owner_cards, transition_to: :owner_balances
    end

    state :owner_balances do
      event :add_owner_balances, transition_to: :companion_cards,
            if: -> (of) { of.companion.present? && of.companion.eligible? }
      event :add_owner_balances, transition_to: :companion_balances,
            if: -> (of) { of.companion.present? }
      event :add_owner_balances, transition_to: :spending,
            if: -> (of) { of.owner.eligible? }
      event :add_owner_balances, transition_to: :phone_number
    end

    state :companion_cards do
      event :add_companion_cards, transition_to: :companion_balances
    end

    state :companion_balances do
      event :add_companion_balances, transition_to: :spending,
            if: -> (of) { of.owner.eligible? || of.companion.eligible? }
      event :add_companion_balances, transition_to: :phone_number
    end

    state :spending do
      event :add_spending, transition_to: :readiness
    end

    state :readiness do
      event :add_readiness, transition_to: :phone_number
    end

    state :phone_number do
      event :add_or_skip_phone_number, transition_to: :complete
    end

    state :complete
  end

  private

  def load_workflow_state
    account.onboarding_state
  end

  def persist_workflow_state(new_value)
    account.update!(onboarding_state: new_value)
  end
end
