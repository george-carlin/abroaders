class RemoveReadinessStatuses < ActiveRecord::Migration[5.0]
  def change
    add_column :people, :ready, :boolean, null: false, default: false
    add_column :people, :unreadiness_reason, :string

    drop_table :readiness_statuses do |t|
      t.integer  :person_id,  null: false
      t.boolean  :ready,      null: false
      t.string   :unreadiness_reason
      t.timestamps null: false
      t.index :person_id
      t.foreign_key :people, on_delete: :cascade
    end
  end
end
