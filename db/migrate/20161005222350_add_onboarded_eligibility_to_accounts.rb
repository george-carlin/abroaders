class AddOnboardedEligibilityToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :onboarded_eligibility, :boolean, default: false, null: false
  end
end
