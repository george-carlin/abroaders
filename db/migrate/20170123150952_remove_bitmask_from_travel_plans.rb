class RemoveBitmaskFromTravelPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :travel_plans, :accepts_economy, :boolean, null: false, default: false
    add_column :travel_plans, :accepts_premium_economy, :boolean, null: false, default: false
    add_column :travel_plans, :accepts_business_class, :boolean, null: false, default: false
    add_column :travel_plans, :accepts_first_class, :boolean, null: false, default: false

    remove_column :travel_plans, :acceptable_classes, :integer
  end
end
