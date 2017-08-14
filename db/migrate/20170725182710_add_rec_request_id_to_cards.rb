class AddRecRequestIdToCards < ActiveRecord::Migration[5.0]
  def change
    add_column :cards, :recommendation_request_id, :integer
    add_foreign_key :cards, :recommendation_requests, on_delete: :nullify
  end
end
