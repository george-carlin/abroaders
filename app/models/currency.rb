class Currency < ApplicationRecord

  # Validations

  validates :name, presence: true, uniqueness: true
  validates :award_wallet_id, presence: true, uniqueness: true

end
