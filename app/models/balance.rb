class Balance < ApplicationRecord

  # Validations

  validates :currency, presence: true
  validates :currency_id, uniqueness: { scope: :user_id }
  validates :user, presence: true
  validates :value,
    numericality: { greater_than_or_equal_to: 0 },
    presence: true

  # Associations

  belongs_to :user
  belongs_to :currency

end
