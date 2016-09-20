class AddAllianceToCurrencies < ActiveRecord::Migration[5.0]
  def change
    add_column :currencies, :alliance_id, :integer, null: true
  end
end
