class AddAdminIdToRecommendationNotes < ActiveRecord::Migration[5.0]
  def change
    add_column :recommendation_notes, :admin_id, :integer
    add_index :recommendation_notes, :admin_id
    add_foreign_key :recommendation_notes, :admins, on_delete: :restrict

    reversible do |d|
      d.up do
        erik = Admin.find_by!(email: 'erik@abroaders.com')
        RecommendationNote.update_all(admin_id: erik.id)
      end
    end

    change_column_null :recommendation_notes, :admin_id, false
  end
end
