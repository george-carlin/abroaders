class CardOffer < ApplicationRecord

  # Attributes

  enum status: [:live, :expired]

  delegate :name, to: :card, prefix: true
  delegate :bank_name, to: :card

  # Validations

  validates :cost,
    presence: true,
    numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE
    }
  validates :days,
    presence: true,
    numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE
    }
  validates :points_awarded,
    presence: true,
    numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE
    }
  validates :status, presence: true
  validates :spend,
    presence: true,
    numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE
    }

  # Associations

  belongs_to :card

end
