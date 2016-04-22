class AddOnboardedTravelPlansToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :onboarded_travel_plans, :boolean, null: false, default: false
  end
end
