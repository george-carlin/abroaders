class Airport < Destination
  IATA_CODE_REGEX = /\A[A-Z]{3}\z/i

  # Our list of airports is based on data that we got from miles.biz. Note that
  # if the airport name according to miles.biz ended in 'Airport', we've
  # stripped that off the end before saving to our DB.

  validates :parent, presence: true
  validates :code, format: { with: IATA_CODE_REGEX }

  validate :parent_is_correct_type

  private

  def parent_is_correct_type
    if parent.present? && parent.type.present? && parent.type != "City"
      errors.add(:parent, "must be a city")
    end
  end
end
