class City < Destination
  validates :parent, presence: true

  validate :parent_is_correct_type

  private

  def parent_is_correct_type
    if parent.present? && parent.type.present? && %w[State Country].exclude?(parent.type)
      errors.add(:parent, "type is invalid")
    end
  end
end
