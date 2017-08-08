class AddMoreInfoToAdmins < ActiveRecord::Migration[5.0]
  def change
    change_column_null :admins, :last_name, false
    add_column :admins, :bio, :text
    add_column :admins, :job_title, :string
  end
end
