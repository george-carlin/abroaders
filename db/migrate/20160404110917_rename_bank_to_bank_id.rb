class RenameBankToBankId < ActiveRecord::Migration[5.0]
  def change
    remove_column :cards, :bank, :integer, null: false
    remove_index :cards, column: :bank_id
    add_column    :cards, :bank_id, :integer, null: false, index: true
    add_index :cards, :bank_id
  end
end
