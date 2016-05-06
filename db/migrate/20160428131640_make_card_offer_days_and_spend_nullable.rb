class MakeCardOfferDaysAndSpendNullable < ActiveRecord::Migration[5.0]
  def up
    change_column :card_offers, :spend, :integer, default: 0,  null: true
    change_column :card_offers, :days, :integer, default: 90, null: true
  end

  def down
    change_column :card_offers, :spend, :integer, default: 0,  null: false
    change_column :card_offers, :days, :integer, default: 90, null: false
  end
end
