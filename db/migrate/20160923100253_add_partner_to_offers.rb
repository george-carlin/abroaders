class AddPartnerToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :partner, :integer
    add_index  :offers, :partner
  end
end
