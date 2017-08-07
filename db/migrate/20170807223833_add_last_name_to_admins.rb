class AddLastNameToAdmins < ActiveRecord::Migration[5.0]
  def change
    add_column :admins, :last_name, :string
    rename_column :admins, :name, :first_name
  end
end
