class AddTimestampsToSpendingInfos < ActiveRecord::Migration[5.0]
  def change
    change_table :spending_infos do |t|
      t.timestamps null: false
    end
  end
end
