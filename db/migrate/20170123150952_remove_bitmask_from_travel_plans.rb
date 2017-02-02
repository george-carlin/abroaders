class RemoveBitmaskFromTravelPlans < ActiveRecord::Migration[5.0]
  class TravelPlan < ActiveRecord::Base
    self.inheritance_column = :_no_sti
  end

  def change
    add_column :travel_plans, :accepts_economy, :boolean, null: false, default: false
    add_column :travel_plans, :accepts_premium_economy, :boolean, null: false, default: false
    add_column :travel_plans, :accepts_business_class, :boolean, null: false, default: false
    add_column :travel_plans, :accepts_first_class, :boolean, null: false, default: false

    # The bitmask_attributes gem will have been removed by the time this migration runs,
    # so don't rely on it! Figure out the acceptable classes ourselves based on the int
    # value of the column.
    #
    # The integer will be between 0 and 15, because it's a 4-bit binary number.
    reversible do |d|
      d.up do
        TravelPlan.pluck(:id, :acceptable_classes).each do |id, ac|
          TravelPlan.update(
            id,
            accepts_economy:         ac % 2 == 1,
            accepts_premium_economy: (ac >> 1) % 2 == 1,
            accepts_business_class:  (ac >> 2) % 2 == 1,
            accepts_first_class:     (ac >> 3) % 2 == 1,
          )
        end
      end
      d.down do
        TravelPlan.pluck(
          :id,
          :accepts_economy,
          :accepts_premium_economy,
          :accepts_business_class,
          :accepts_first_class,
        ).each do |id, e, pe, b, f|
          bitmask = if     f &&  b &&  pe &&  e
                      15
                    elsif  f &&  b &&  pe && !e
                      14
                    elsif  f &&  b && !pe &&  e
                      13
                    elsif  f &&  b && !pe && !e
                      12
                    elsif  f && !b &&  pe &&  e
                      11
                    elsif  f && !b &&  pe && !e
                      10
                    elsif  f && !b && !pe &&  e
                       9
                    elsif  f && !b && !pe && !e
                       8
                    elsif !f &&  b &&  pe &&  e
                       7
                    elsif !f &&  b &&  pe && !e
                       6
                    elsif !f &&  b && !pe &&  e
                       5
                    elsif !f &&  b && !pe && !e
                       4
                    elsif !f && !b &&  pe &&  e
                       3
                    elsif !f && !b &&  pe && !e
                       2
                    elsif !f && !b && !pe &&  e
                       1
                    elsif !f && !b && !pe && !e
                       0
                    end
          TravelPlan.update(id, acceptable_classes: bitmask)
        end
        change_column_null :travel_plans, :acceptable_classes, false
      end
    end

    remove_column :travel_plans, :acceptable_classes, :integer
  end
end
