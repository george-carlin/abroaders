class AddOnboardedTypeToAccount < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :onboarded_type, :boolean, null: false, default: false
  end
end
