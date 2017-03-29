# A Card is a specific copy of a CardProduct. If 10 people have a Chase
# Sapphire credit card, then there are 10 Cards (one in each person's wallet),
# but only one card *product* (the general concept of a Chase Sapphire card).
#
# A card has the following timestamps, all of which are nullable:
#
# @!attribute opened_on
#   the date the user was approved for the card and their account was opened.
#
# @!attribute earned_at
#   the date the user earned their signup bonus. (It might be the same date
#   they opened the card, if they signed up through an 'on approval' offer) We
#   don't actually have anything in place yet to update this, so this column is
#   currently null for all cards :/
#
# @!attribute closed_on
#   the date the user's card expired or they closed the card's account.
class Card < ApplicationRecord
  def status
    status_model.name
  end

  %w[open closed].each do |status|
    define_method "#{status}?" do
      self.status == status
    end
  end

  # Validations

  # TODO why is this validation here and not in a form object?
  validates :person, presence: true

  # Associations

  belongs_to :product, class_name: 'CardProduct'
  belongs_to :person
  belongs_to :card_application
  has_one :card_recommendation, through: :card_application

  # Callbacks

  # Scopes

  private

  def status_model
    Card::Status.build(self)
  end
end
