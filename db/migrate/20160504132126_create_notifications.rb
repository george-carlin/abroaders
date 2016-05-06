class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.references :account, foreign_key: true
      t.integer :record_id, null: false
      t.boolean :seen, default: false, null: false
      t.string :type, null: false

      t.index :record_id
      t.index :seen
      t.index [:account_id, :seen]

      t.timestamps
    end

    add_column :accounts, :unseen_notifications_count, :integer, default: 0, null: false
    add_column :people, :last_recommendations_at, :datetime
  end
end
