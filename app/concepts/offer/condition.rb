class Offer < ApplicationRecord
  # When are the points awarded?
  Condition = Types::Strict::String.enum(
    'on_approval', # as soon as approved for card
    'on_first_purchase', # once you make 1st purchase with card
    'on_minimum_spend', # if you spend $X within Y days
    'no_bonus', # no bonus awarded, the application just gets the card
  )

  # takes a condition and returns whether the 'days' attribute is required for
  # offers with this condition.
  #
  # @param condition [String]
  def Condition.days?(condition)
    self.(condition) # raise if it's not a valid condition
    %w[on_first_purchase on_minimum_spend].include?(condition)
  end

  # takes a condition and returns whether the 'points_awarded' attribute is
  # required for offers with this condition.
  #
  # @param condition [String]
  def Condition.points_awarded?(condition)
    self.(condition) # raise if it's not a valid condition
    condition != 'no_bonus'
  end

  # takes a condition and returns whether the 'spend' attribute is required for
  # offers with this condition.
  #
  # @param condition [String]
  def Condition.spend?(condition)
    self.(condition) # raise if it's not a valid condition
    condition == 'on_minimum_spend'
  end
end

Offer::Condition.freeze
