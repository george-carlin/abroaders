class CreateRecommendationRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :recommendation_requests do |t|
      t.references :person, foreign_key: { on_delete: :cascade }, index: true, null: false

      t.string :status, null: false

      t.timestamps
    end
  end
end
