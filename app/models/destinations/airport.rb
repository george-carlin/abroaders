class Airport < Destination
  IATA_CODE_REGEX = /\A[A-Z]{3}\z/i

  has_and_belongs_to_many :accounts,
                          join_table: :accounts_home_airports,
                          foreign_key: :airport_id

  validates :parent, presence: true
  validates :code, format: { with: IATA_CODE_REGEX }

  validate :parent_is_correct_type

  private

  def parent_is_correct_type
    if parent.present? && parent.type.present? && %w[City State Country].exclude?(parent.type)
      errors.add(:parent, "type is invalid")
    end
  end
end
