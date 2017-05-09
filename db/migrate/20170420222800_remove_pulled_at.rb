class RemovePulledAt < ActiveRecord::Migration[5.0]
  def change
    remove_column :cards, :pulled_at, :datetime
  end
end
