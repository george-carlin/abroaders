class CreateReadinessStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :readiness_statuses do |t|
      t.integer :passenger_id, null: false, index: { unique: true }
      t.boolean :ready, null: false
      t.string  :unreadiness_reason
      t.timestamps

      t.foreign_key :passengers, on_delete: :cascade
    end
  end
end
