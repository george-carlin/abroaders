class CardAccount < ApplicationRecord

  # Attributes

  enum status: [:recommended, :declined, :reconsideration, :pending_decision,
                :manual_pending, :denied, :manual_denied, :bonus_challenge,
                :open, :closed, :converted]

  # Validations

  validates :card, presence: true
  validates :user, presence: true
  validates :status, presence: true

  # Associations

  belongs_to :card
  belongs_to :user

end
