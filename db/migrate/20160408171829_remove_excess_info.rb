class RemoveExcessInfo < ActiveRecord::Migration[5.0]
  def change
    remove_column :passengers, :middle_names, :string
    remove_column :passengers, :last_name,    :string,                  null: false
    remove_column :passengers, :phone_number, :string,                  null: false
    remove_column :passengers, :text_message, :boolean, default: false, null: false
    remove_column :passengers, :whatsapp,     :boolean, default: false, null: false
    remove_column :passengers, :imessage,     :boolean, default: false, null: false

    remove_column :accounts,   :time_zone, :string
  end
end
