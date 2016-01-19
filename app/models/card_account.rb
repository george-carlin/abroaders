class CardAccount < ApplicationRecord

  # Attributes

  enum status: [:recommended, :declined, :reconsideration, :pending_decision,
                :manual_pending, :denied, :manual_denied, :bonus_challenge,
                :open, :closed, :converted]

  delegate :brand, :type, :bp, :name, :identifier, :bank_name, to: :card,
    prefix: true

  # Validations

  validates :card, presence: true
  validates :user, presence: true
  validates :status, presence: true

  # Associations

  belongs_to :card
  belongs_to :user

end
