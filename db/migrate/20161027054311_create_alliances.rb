class CreateAlliances < ActiveRecord::Migration[5.0]
  def change
    create_table :alliances do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_foreign_key :currencies, :alliances
  end
end
