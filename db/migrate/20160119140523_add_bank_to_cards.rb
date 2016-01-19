class AddBankToCards < ActiveRecord::Migration[5.0]
  def change
    add_column :cards, :bank, :integer, null: false
    add_index :cards, :bank
  end
end
