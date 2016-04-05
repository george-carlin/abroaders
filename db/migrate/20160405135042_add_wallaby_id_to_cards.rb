class AddWallabyIdToCards < ActiveRecord::Migration[5.0]
  def change
    add_column :cards, :wallaby_id, :string
    add_index :cards, :wallaby_id
  end
end
