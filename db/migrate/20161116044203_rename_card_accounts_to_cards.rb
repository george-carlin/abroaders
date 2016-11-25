class RenameCardAccountsToCards < ActiveRecord::Migration[5.0]
  def change
    rename_table :card_accounts, :cards
  end
end
