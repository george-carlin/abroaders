class Country < Destination
  validates :parent, presence: true

  validate :parent_is_region

  private

  def parent_is_region
    if parent.present? && parent.type.present? && parent.type != "Region"
      errors.add(:parent, "must be a region")
    end
  end
end
