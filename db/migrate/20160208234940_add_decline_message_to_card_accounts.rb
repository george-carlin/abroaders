class AddDeclineMessageToCardAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :card_accounts, :decline_reason, :string
  end
end
