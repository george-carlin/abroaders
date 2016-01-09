class CreateAirports < ActiveRecord::Migration[5.0]
  def change
    create_table :airports do |t|
      t.string :name, null: false, index: true
      t.string :iata_code, null: false, index: :unique, limit: 3

      t.timestamps
    end
  end
end
