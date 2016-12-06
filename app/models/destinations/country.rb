class Country < Destination
  validates :parent, presence: true

  validate :parent_is_region

  private

  def parent_is_region
    return unless !parent.nil? && !parent.type.nil? && parent.type != "Region"
    errors.add(:parent, "must be a region")
  end
end
