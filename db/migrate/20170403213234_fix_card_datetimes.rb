class FixCardDatetimes < ActiveRecord::Migration[5.0]
  def change
    # forget this col, it's never even been used:
    remove_column :cards, :earned_at, :date
    rename_column :cards, :applied_at, :applied_on
    rename_column :cards, :opened_at, :opened_on
    rename_column :cards, :closed_at, :closed_on

    reversible do |d|
      d.up do
        change_column :cards, :clicked_at, :datetime
        change_column :cards, :declined_at, :datetime
        change_column :cards, :redenied_at, :datetime
        change_column :cards, :called_at, :datetime
        change_column :cards, :nudged_at, :datetime
        change_column :cards, :denied_at, :datetime
        change_column :cards, :recommended_at, :datetime
      end
      d.down do
        change_column :cards, :clicked_at, :date
        change_column :cards, :declined_at, :date
        change_column :cards, :redenied_at, :date
        change_column :cards, :called_at, :date
        change_column :cards, :nudged_at, :date
        change_column :cards, :denied_at, :date
        change_column :cards, :recommended_at, :date
      end
    end
  end
end
