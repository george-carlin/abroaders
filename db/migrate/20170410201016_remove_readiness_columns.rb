class RemoveReadinessColumns < ActiveRecord::Migration[5.0]
  def change
    # These columns are now longer needed now that we have the new recrequest system
    remove_column :people, :last_recommendations_at, :datetime
    remove_column :people, :ready, :boolean, default: false, null: false
    remove_column :people, :unreadiness_reason, :string
  end
end
