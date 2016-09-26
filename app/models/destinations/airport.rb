class Airport < Destination
  IATA_CODE_REGEX = /\A[A-Z]{3}\z/i

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
