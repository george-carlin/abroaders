class Balance < ApplicationRecord
  # Attributes

  delegate :name, to: :currency, prefix: true

  # these should be removed from the model and handled by Reform, but we
  # still need them for now because of the epic pile of shit that is the
  # `BalancesSurvey class:
  validates :currency, presence: true
  validates :person, presence: true
  validates :value,
            numericality: { greater_than_or_equal_to: 0 },
            presence: true

  # Associations

  belongs_to :person
  belongs_to :currency
end
