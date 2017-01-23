class RemoveBitmaskFromTravelPlans < ActiveRecord::Migration[5.0]
  def up
    add_column :travel_plans, :accepts_economy, :boolean, null: false, default: false
    add_column :travel_plans, :accepts_premium_economy, :boolean, null: false, default: false
    add_column :travel_plans, :accepts_business_class, :boolean, null: false, default: false
    add_column :travel_plans, :accepts_first_class, :boolean, null: false, default: false

    # The bitmask_attributes gem will have been removed by the time this migration runs,
    # so don't rely on it! Figure out the acceptable classes ourselves based on the int
    # value of the column.
    #
    # The integer will be between 0 and 15, because it's a 4-bit binary number.
    TravelPlan.pluck(:id, :acceptable_classes).each do |id, ac|
      TravelPlan.update(
        id,
        accepts_economy:         ac % 2 == 1,
        accepts_premium_economy: (ac >> 1) % 2 == 1,
        accepts_business_class:  (ac >> 2) % 2 == 1,
        accepts_first_class:     (ac >> 3) % 2 == 1,
      )
    end

    remove_column :travel_plans, :acceptable_classes, :integer, null: false
  end
end
