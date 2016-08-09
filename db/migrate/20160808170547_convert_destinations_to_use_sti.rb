class ConvertDestinationsToUseSti < ActiveRecord::Migration[5.0]
  class Destination < ActiveRecord::Base
    self.inheritance_column = :_no_sti
  end

  def change
    add_column :destinations, :type_str, :string, index: true

    reversible do |d|
      d.up do
        Destination.where(type: 0).update_all(type_str: "Airport")
        Destination.where(type: 1).update_all(type_str: "City")
        Destination.where(type: 2).update_all(type_str: "State")
        Destination.where(type: 3).update_all(type_str: "Country")
        Destination.where(type: 4).update_all(type_str: "Region")
      end
      d.down do
        Destination.where(type_str: "Airport").update_all(type: 0)
        Destination.where(type_str: "City"   ).update_all(type: 1)
        Destination.where(type_str: "State"  ).update_all(type: 2)
        Destination.where(type_str: "Country").update_all(type: 3)
        Destination.where(type_str: "Region" ).update_all(type: 4)
      end
    end

    change_column_null :destinations, :type_str, false

    remove_index  :destinations, column: :type
    remove_column :destinations, :type, :integer, null: false

    rename_column :destinations, :type_str, :type
    add_index :destinations, :type
    add_index :destinations, [:code, :type], unique: true
  end
end
