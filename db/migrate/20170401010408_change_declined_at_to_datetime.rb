class ChangeDeclinedAtToDatetime < ActiveRecord::Migration[5.0]
  def change
    reversible do |d|
      d.up do
        change_column :cards, :clicked_at, :datetime
        change_column :cards, :declined_at, :datetime
      end
      d.down do
        change_column :cards, :clicked_at, :date
        change_column :cards, :declined_at, :date
      end
    end
  end
end
