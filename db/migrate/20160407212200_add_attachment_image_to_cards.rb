class AddAttachmentImageToCards < ActiveRecord::Migration
  def change
    add_attachment :cards, :image, null: false
    remove_column :cards, :image_name, :string
  end
end
