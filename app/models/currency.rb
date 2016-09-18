class Currency < ApplicationRecord

  # Validations

  validates :name, presence: true, uniqueness: true
  validates :award_wallet_id, presence: true, uniqueness: true

  belongs_to_fake_db_model :alliance

  # Scopes

  scope :survey, -> { where(shown_on_survey: true) }
end
