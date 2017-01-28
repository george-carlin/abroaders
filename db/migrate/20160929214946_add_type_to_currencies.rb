class AddTypeToCurrencies < ActiveRecord::Migration[5.0]
  def change
    add_column :currencies, :type, :string, null: false
    add_index :currencies, :type
  end
end
