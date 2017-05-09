class DropNotifications < ActiveRecord::Migration[5.0]
  def change
    drop_table :notifications
    remove_column :accounts, :unseen_notifications_count, :integer, default: 0, null: false
  end
end
