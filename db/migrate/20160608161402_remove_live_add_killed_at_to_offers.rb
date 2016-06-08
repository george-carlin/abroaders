class RemoveLiveAddKilledAtToOffers < ActiveRecord::Migration[5.0]
  def change
    remove_column :offers, :live, :boolean
    add_column :offers, :killed_at, :datetime
    add_index :offers, :killed_at
  end
end
