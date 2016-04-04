class RenameCardBrandToNetwork < ActiveRecord::Migration[5.0]
  def change
    rename_column :cards, :brand, :network
  end
end
