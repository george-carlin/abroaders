class RemoveCitizenship < ActiveRecord::Migration[5.0]
  def change
    remove_column :spending_infos, :citizenship, default: 0, null: false
  end
end
