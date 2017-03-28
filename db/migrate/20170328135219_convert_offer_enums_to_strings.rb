class ConvertOfferEnumsToStrings < ActiveRecord::Migration[5.0]
  PARTNERS = {
    'award_wallet' => 2,
    'card_benefit' => 3,
    'card_ratings' => 0,
    'credit_cards' => 1,
  }.freeze

  CONDITIONS = {
    'on_minimum_spend' =>  0, # points awarded if you spend $X within Y days
    'on_approval' =>       1, # points awarded as soon as approved for card
    'on_first_purchase' => 2, # points awarded once you make 1st purchase with card
  }.freeze

  def change
    add_column :offers, :partner_new, :string, index: true, default: 'none', null: false
    add_column :offers, :condition_new, :string, index: true

    PARTNERS.each do |name, int|
      Offer.where(partner: int).update_all(partner_new: name)
    end

    CONDITIONS.each do |name, int|
      Offer.where(condition: int).update_all(condition_new: name)
    end

    Offer.where(partner: nil).update_all(partner_new: 'none')

    remove_column :offers, :partner, :integer, index: true
    rename_column :offers, :partner_new, :partner

    remove_column :offers, :condition, :integer, index: true, default: 0, null: false
    change_column_null :offers, :condition_new, false
    rename_column :offers, :condition_new, :condition
  end
end
