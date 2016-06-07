class AddKilledAtIndexToOffers < ActiveRecord::Migration[5.0]
  def change
    add_index :offers, :killed_at
  end
end
