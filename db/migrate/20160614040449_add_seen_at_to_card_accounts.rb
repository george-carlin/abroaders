class AddSeenAtToCardAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :card_accounts, :seen_at, :datetime
    add_index :card_accounts, :seen_at
  end
end
