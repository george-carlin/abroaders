class City < Destination
  validates :parent, presence: true

  validate :parent_is_country

  private

  def parent_is_country
    return unless !parent.nil? && !parent.type.nil? && parent.type != "Country"
    errors.add(:parent, "must be a country")
  end
end
