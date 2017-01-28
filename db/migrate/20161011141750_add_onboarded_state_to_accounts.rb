class AddOnboardedStateToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :onboarding_state, :string, default: "home_airports", null: false
    add_index :accounts, :onboarding_state

    remove_column :accounts, :onboarded_home_airports, :boolean, default: false, null: false
    remove_column :accounts, :onboarded_travel_plans,  :boolean, default: false, null: false
    remove_column :accounts, :onboarded_type,          :boolean, default: false, null: false
    remove_column :people,   :onboarded_balances,      :boolean, default: false, null: false
    remove_column :people,   :onboarded_cards,         :boolean, default: false, null: false
  end
end
