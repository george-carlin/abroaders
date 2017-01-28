class AddOrderToAlliances < ActiveRecord::Migration[5.0]
  def change
    add_column :alliances, :order, :integer, index: { unique: true }, null: false
  end
end
