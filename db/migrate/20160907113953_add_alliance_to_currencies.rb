class AddAllianceToCurrencies < ActiveRecord::Migration[5.0]
  def change
    add_column :currencies, :alliance_name, :string, null: false
  end
end
