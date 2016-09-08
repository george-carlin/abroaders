class Currency < ApplicationRecord

  # Validations

  validates :name, presence: true, uniqueness: true
  validates :award_wallet_id, presence: true, uniqueness: true

  # Methods

  def alliance
    @alliance ||= Alliance.find(alliance_id)
  end

  def alliance=(new_alliance)
    self.alliance_id = new_alliance.id
  end

  def alliance_id=(alliance_id)
    @alliance = nil
    super
  end

  # Scopes

  scope :survey, -> { where(shown_on_survey: true) }
end
