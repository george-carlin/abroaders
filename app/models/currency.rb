class Currency < ApplicationRecord

  # Validations

  validates :name, presence: true, uniqueness: true
  validates :award_wallet_id, presence: true, uniqueness: true

  def self.raw_data
    JSON.parse(File.read(Rails.root.join("lib", "data", "currencies.json")))
  end

end
