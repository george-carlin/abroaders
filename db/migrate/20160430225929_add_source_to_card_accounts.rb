class AddSourceToCardAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :card_accounts, :source, :integer
    add_index :card_accounts, :source

    reversible do |d|
      d.up do
        change_column :card_accounts, :source, :integer, null: false
      end
    end
  end
end
