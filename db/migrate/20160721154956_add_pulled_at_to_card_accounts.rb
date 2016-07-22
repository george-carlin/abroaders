class AddPulledAtToCardAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :card_accounts, :pulled_at, :datetime
    add_index :card_accounts, :pulled_at
  end
end
