class AddValueToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :value_cents, :integer
  end
end
