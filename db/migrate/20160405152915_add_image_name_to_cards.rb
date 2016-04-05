class AddImageNameToCards < ActiveRecord::Migration[5.0]
  def change
    add_column :cards, :image_name, :string, null: false
  end
end
