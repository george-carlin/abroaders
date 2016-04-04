class RenameCardIdentifierToCode < ActiveRecord::Migration[5.0]
  def change
    remove_index :cards, column: :identifier, unique: true
    rename_column :cards, :identifier, :code
  end
end
