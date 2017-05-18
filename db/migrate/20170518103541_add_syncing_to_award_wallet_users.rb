class AddSyncingToAwardWalletUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :award_wallet_users, :syncing, :boolean, default: false, null: false
  end
end
