class City < Destination
  validates :parent, presence: true

  validate :parent_is_country

  # Use alias, not alias_attribute, because alias_attribute adds #country?  which
  # conflicts with a method we already have.
  alias country parent
  alias country= parent=
  delegate :name, to: :country, prefix: true

  private

  def parent_is_country
    return unless !parent.nil? && !parent.type.nil? && parent.type != "Country"
    errors.add(:parent, "must be a country")
  end
end
