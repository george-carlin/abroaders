class RemoveCardCurrencyRequirement < ActiveRecord::Migration[5.0]
  def change
    change_column_null :cards, :currency_id, true
  end
end
