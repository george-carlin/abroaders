class AddClickedAtToCardAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :card_accounts, :clicked_at, :datetime
  end
end
