class Airport < Destination
  IATA_CODE_REGEX = /\A[A-Z]{3}\z/i

  has_and_belongs_to_many :accounts,
                          join_table: :accounts_home_airports,
                          foreign_key: :airport_id

  # Our list of airports is based on data that we got from miles.biz. Note that
  # if the airport name according to miles.biz ended in 'Airport', we've
  # stripped that off the end before saving to our DB. We've also stripped all
  # diacritics (using I18n.transliterate) to e.g. "São Paulo" is saved in our
  # DB as "Sao Paulo"

  validates :parent, presence: true
  validates :code, format: { with: IATA_CODE_REGEX }

  validate :parent_is_correct_type

  # Use alias, not alias_attribute, because alias_attribute adds #city?  which
  # conflicts with a method we already have.
  alias city parent
  alias city= parent=
  delegate :name, to: :city, prefix: true
  delegate :country, to: :city

  def full_name
    if name.downcase.include?(city_name.downcase)
      "#{name} (#{code})"
    else
      "#{city_name} #{name} (#{code})"
    end
  end

  private

  def parent_is_correct_type
    return unless !parent.nil? && !parent.type.nil? && parent.type != "City"
    errors.add(:parent, "must be a city")
  end
end
