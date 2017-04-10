class RemovePersonLastReceivedRecommendations < ActiveRecord::Migration[5.0]
  def change
    remove_column :people, :last_recommendations_at, :datetime
  end
end
