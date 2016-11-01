class AddPromoCodeToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :promo_code, :string
  end
end
