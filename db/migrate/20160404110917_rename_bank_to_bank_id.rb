class RenameBankToBankId < ActiveRecord::Migration[5.0]
  def change
    remove_column :cards, :bank, :integer, null: false
    add_column    :cards, :bank_id, :integer, null: false
    add_index     :cards, :bank_id
  end
end
