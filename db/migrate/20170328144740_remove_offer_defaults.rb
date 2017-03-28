class RemoveOfferDefaults < ActiveRecord::Migration[5.0]
  def change
    change_column_default :offers, :cost,  nil
    change_column_default :offers, :spend, nil
    change_column_default :offers, :days,  nil
  end
end
