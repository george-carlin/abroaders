class CreateEligibilities < ActiveRecord::Migration[5.0]
  def change
    create_table :eligibilities do |t|
      t.references :person, foreign_key: { on_delete: :cascade }, null: false
      t.boolean :eligible, null: false

      t.timestamps
    end
  end
end
