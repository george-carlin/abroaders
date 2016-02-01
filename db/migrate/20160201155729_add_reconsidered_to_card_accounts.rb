class AddReconsideredToCardAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :card_accounts, :reconsidered, :boolean,
                               default: false, null: false
  end
end
