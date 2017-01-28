class AddDeclinedAtToCardAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :card_accounts, :declined_at, :datetime
  end
end
