class AddTypeToCurrencies < ActiveRecord::Migration[5.0]
  class Currency < ActiveRecord::Base;end

  def change
    add_column :currencies, :type, :string
    add_index :currencies, :type

    Currency.update_all(type: "airline")

    change_column_null :currencies, :type, false
  end
end
