class RemoveLiveFromOffers < ActiveRecord::Migration[5.0]
  def change
    remove_column :offers, :live, :boolean
  end
end
