class AddAwardWalletEmailToPeople < ActiveRecord::Migration[5.0]
  def change
    add_column :people, :award_wallet_email, :string
  end
end
