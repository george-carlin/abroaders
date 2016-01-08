class Airport < ApplicationRecord

  IATA_CODE_REGEX = /\A[A-Z]{3}\z/i

  # Name doesn't have to be unique since there are some airports in the world
  # with the same name as each other.
  validates :name, presence: true
  validates :iata_code, presence: true, uniqueness: true,
            format: IATA_CODE_REGEX

  # Callbacks

  before_save { self.iata_code = self.iata_code.upcase }

end
