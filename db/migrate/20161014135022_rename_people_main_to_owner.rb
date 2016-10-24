class RenamePeopleMainToOwner < ActiveRecord::Migration[5.0]
  def change
    rename_column :people, :main, :owner
  end
end
