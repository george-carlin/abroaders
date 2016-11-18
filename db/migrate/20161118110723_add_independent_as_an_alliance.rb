class AddIndependentAsAnAlliance < ActiveRecord::Migration[5.0]
  class Currency < ActiveRecord::Base
  end

  class Alliance < ActiveRecord::Base
  end
  def change
    independent = Alliance.find_or_create_by!(name: 'Independent')
    Currency.where(alliance_id: nil).update_all(alliance_id: independent.id)
    change_column_null :currencies, :alliance_id, false
  end
end
