class AddRecommendedByToRecs < ActiveRecord::Migration[5.0]
  def change
    add_column :cards, :recommended_by_id, :integer, index: true

    add_foreign_key :cards, :admins, column: :recommended_by_id, on_delete: :nullify
  end
end
