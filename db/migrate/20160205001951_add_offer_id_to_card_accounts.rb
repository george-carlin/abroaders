class AddOfferIdToCardAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :card_accounts, :offer_id, :integer, index: true
    add_foreign_key :card_accounts, :card_offers, column: :offer_id,
                                                  on_delete: :restrict
  end
end
