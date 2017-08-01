class AddNameToAdmins < ActiveRecord::Migration[5.0]
  def change
    add_column :admins, :name, :string

    reversible do |d|
      d.up do
        Admin.find_each do |admin|
          admin.update!(name: admin.email.split('@').first.capitalize)
        end
      end
    end

    change_column_null :admins, :name, false
  end
end
