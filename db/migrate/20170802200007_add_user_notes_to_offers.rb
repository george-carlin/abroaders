class AddUserNotesToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :user_notes, :text
  end
end
