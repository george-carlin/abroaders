class MoveOnboardingToPassengers < ActiveRecord::Migration[5.0]
  def change
    remove_column :accounts, :onboarding_stage, :integer, default: 0,  null: false
    add_column :people, :onboarded_cards,    :boolean, default: false, null: false
    add_column :people, :onboarded_balances, :boolean, default: false, null: false
  end
end
