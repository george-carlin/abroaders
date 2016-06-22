class CreateRecommendationNotes < ActiveRecord::Migration[5.0]
  def change
    create_table :recommendation_notes do |t|
      t.text :content, null: false
      t.references :account, index: true, foreign_key: { on_delete: :cascade }, null: false
      t.timestamps
    end
  end
end
