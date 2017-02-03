class CreateAlliances < ActiveRecord::Migration[5.0]
  class Alliance < ActiveRecord::Base
  end

  def change
    create_table :alliances do |t|
      t.string :name, null: false

      t.timestamps
    end

    reversible do |d|
      d.up do
        [
          [1, 'OneWorld'], [2, 'StarAlliance'], [3, 'SkyTeam'],
        ].each do |id, name|
          Alliance.create!(id: id, name: name)
        end
      end
    end

    add_foreign_key :currencies, :alliances
  end
end
