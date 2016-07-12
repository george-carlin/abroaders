class Balance < ApplicationRecord

  # Attributes

  delegate :name, to: :currency, prefix: true

  # Validations

  validates :currency, presence: true
  validates :person, presence: true
  validates :value,
    numericality: { greater_than_or_equal_to: 0 },
    presence: true

  # Associations

  belongs_to :person
  belongs_to :currency

end
