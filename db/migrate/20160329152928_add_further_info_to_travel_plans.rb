class AddFurtherInfoToTravelPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :travel_plans, :further_information, :text
    add_column :travel_plans, :acceptable_classes, :integer, null: false, index: true
  end
end
