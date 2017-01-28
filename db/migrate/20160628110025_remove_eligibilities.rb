class RemoveEligibilities < ActiveRecord::Migration[5.0]
  def change
    add_column :people, :eligible, :boolean

    drop_table :eligibilities do |t|
      t.integer  :person_id,  null: false
      t.boolean  :eligible,   null: false
      t.timestamps null: false
      t.index :person_id
      t.foreign_key :people, on_delete: :cascade
    end
  end
end
