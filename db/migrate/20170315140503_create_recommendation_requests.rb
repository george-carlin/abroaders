class CreateRecommendationRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :recommendation_requests do |t|
      t.references :person, foreign_key: { on_delete: :cascade }, index: true, null: false

      t.datetime :confirmed_at, index: true
      t.datetime :resolved_at, index: true

      t.timestamps
    end
  end
end
