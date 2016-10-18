class AddOnboardedStateToAccounts < ActiveRecord::Migration[5.0]
  class Account < ActiveRecord::Base
    has_many :people
    has_many :travel_plans
    def owner
      people.find_by(main: true)
    end

    def companion
      people.find_by(main: false)
    end
  end

  class Person < ActiveRecord::Base
    has_one :spending_info

    def onboarded_spending?
      !!spending_info&.persisted?
    end
  end

  class SpendingInfo < ActiveRecord::Base
  end

  # Needs more testing before we run it in production:
  def get_onboarding_state(account)
    if !account.onboarded_home_airports?
      return "home_airports"
    end

    if !account.onboarded_travel_plans?
      return "travel_plan"
    end

    if !account.onboarded_type?
      return account.travel_plans.any? ? "account_type" : "regions_of_interest"
    end

    owner = account.owner
    if owner.eligible?
      if !owner.onboarded_spending?
        return "owner_spending"
      end

      if !owner.onboarded_cards?
        return "owner_cards"
      end
    end

    if !owner.onboarded_balances?
      return "owner_balances"
    end

    if companion = account.companion # could be nil
      if companion.eligible?
        if !companion.onboarded_spending?
          return "companion_spending"
        end

        if !companion.onboarded_cards?
          return "companion_cards"
        end
      end

      if !companion.onboarded_balances?
        return "companion_balances"
      else
        return "complete"
      end
    else
      return "complete"
    end

    raise "unknown onboarding state"
  end

  def change
    add_column :accounts, :onboarding_state, :string, default: "home_airports", null: false
    add_index :accounts, :onboarding_state

    # WARNING! Running this migration up then down again will lose
    # all onboarding data
    reversible do |d|
      d.up do
        Account.reset_column_information
        Account.find_each do |account|
          account.update!(onboarding_state: get_onboarding_state(account))
        end
      end
    end

    remove_column :accounts, :onboarded_home_airports, :boolean, default: false, null: false
    remove_column :accounts, :onboarded_travel_plans,  :boolean, default: false, null: false
    remove_column :accounts, :onboarded_type,          :boolean, default: false, null: false
    remove_column :people,   :onboarded_balances,      :boolean, default: false, null: false
    remove_column :people,   :onboarded_cards,         :boolean, default: false, null: false
  end
end
