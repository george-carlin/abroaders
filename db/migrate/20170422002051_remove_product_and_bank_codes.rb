class RemoveProductAndBankCodes < ActiveRecord::Migration[5.0]
  def change
    remove_column :card_products, :code, :string, null: false
    remove_column :banks, :personal_code, :string, null: false
  end
end
