class AddOnboardedToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :onboarding_stage, :integer, default: 0, null: false
    remove_column :passengers, :has_added_cards,
                                    :boolean, default: false, null: false
    remove_column :passengers, :has_added_balances,
                                    :boolean, default: false, null: false
  end
end
