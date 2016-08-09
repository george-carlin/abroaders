class State < Destination
  validates :parent, presence: true

  validate :parent_is_correct_type

  private

  def parent_is_correct_type
    if parent.present? && parent.type.present? && parent.type != "Country"
      errors.add(:parent, "type is invalid")
    end
  end
end
