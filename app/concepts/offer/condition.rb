class Offer < ApplicationRecord
  # When are the points awarded?
  Condition = Types::Strict::String.enum(
    'on_approval', # as soon as approved for card
    'on_first_purchase', # once you make 1st purchase with card
    'on_minimum_spend', # if you spend $X within Y days
    'no_bonus', # no bonus awarded, the application just gets the card
  )

  def Condition.days?(condition)
    self.(condition) # raise if it's not a valid condition
    %w[on_first_purchase on_minimum_spend].include?(condition)
  end

  def Condition.points_awarded?(condition)
    self.(condition) # raise if it's not a valid condition
    condition != 'no_bonus'
  end

  def Condition.spend?(condition)
    self.(condition) # raise if it's not a valid condition
    condition == 'on_minimum_spend'
  end
end

Offer::Condition.freeze
