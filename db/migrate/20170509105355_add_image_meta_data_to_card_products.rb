class AddImageMetaDataToCardProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :card_products, :image_meta_data, :text
    change_column_null :card_products, :image_file_name, true
    change_column_null :card_products, :image_content_type, true
    change_column_null :card_products, :image_file_size, true
    change_column_null :card_products, :image_updated_at, true
  end
end
