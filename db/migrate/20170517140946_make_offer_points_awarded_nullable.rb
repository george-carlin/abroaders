class MakeOfferPointsAwardedNullable < ActiveRecord::Migration[5.0]
  def change
    change_column_null :offers, :points_awarded, true
  end
end
