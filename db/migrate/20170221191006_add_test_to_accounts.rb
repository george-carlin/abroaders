class AddTestToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :test, :boolean, null: false, default: false
  end
end
