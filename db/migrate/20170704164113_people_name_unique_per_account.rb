class PeopleNameUniquePerAccount < ActiveRecord::Migration[5.0]
  def change
    add_index :people, [:account_id, :first_name], unique: true
  end
end
