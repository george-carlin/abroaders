class AddKilledAtToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :killed_at, :datetime
  end
end
