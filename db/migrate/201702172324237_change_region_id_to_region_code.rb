class ChangeRegionIdToRegionCode < ActiveRecord::Migration[5.0]
  def change
    add_column :destinations, :region_code, :string
    add_column :interest_regions, :region_code, :string
    add_index :interest_regions, [:account_id, :region_code], unique: true

    change_column_null :interest_regions, :region_id, true
  end
end
