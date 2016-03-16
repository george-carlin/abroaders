class Balance < ApplicationRecord

  # Attributes

  delegate :name, to: :currency, prefix: true

  # Validations

  validates :currency, presence: true
  validates :currency_id, uniqueness: { scope: :passenger_id }
  validates :passenger, presence: true
  validates :value,
    numericality: { greater_than_or_equal_to: 0 },
    presence: true

  # Associations

  belongs_to :passenger
  belongs_to :currency

end
