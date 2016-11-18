class AddOrderToAlliances < ActiveRecord::Migration[5.0]
  class Alliance < ActiveRecord::Base
  end

  def change
    add_column :alliances, :order, :integer, index: { unique: true }

    reversible do |d|
      d.up do
        Alliance.find_by(name: 'OneWorld').update(order: 0)
        Alliance.find_by(name: 'StarAlliance').update(order: 1)
        Alliance.find_by(name: 'SkyTeam').update(order: 2)
        Alliance.find_by(name: 'Independent').update(order: 99)
      end
    end

    change_column_null :alliances, :order, false
  end
end
