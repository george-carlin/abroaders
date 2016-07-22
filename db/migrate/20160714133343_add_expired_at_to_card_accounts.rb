class AddExpiredAtToCardAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :card_accounts, :expired_at, :datetime
  end
end
