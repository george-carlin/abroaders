class AddClickedAtToCardAccounts < ActiveRecord::Migration[5.0]
  class CardAccount < ActiveRecord::Base
  end
  def change
    CardAccount.transaction do
      add_column :card_accounts, :clicked_at, :datetime
      CardAccount.reset_column_information
      CardAccount.where.not(applied_at: nil).find_each do |card_account|
        card_account.update_attributes!(
          clicked_at: card_account.applied_at,
          applied_at: nil,
        )
      end
    end
  end
end
