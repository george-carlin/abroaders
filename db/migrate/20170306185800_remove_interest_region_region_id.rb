class RemoveInterestRegionRegionId < ActiveRecord::Migration[5.0]
  def change
    remove_column :interest_regions, :region_id, :integer
    change_column_null :interest_regions, :region_code, false
  end
end
