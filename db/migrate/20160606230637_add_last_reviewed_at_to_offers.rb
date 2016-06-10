class AddLastReviewedAtToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :last_reviewed_at, :datetime
  end
end
