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

  private

  def parent_is_correct_type
    return unless parent.present? && parent.type.present? && parent.type != "City"
    errors.add(:parent, "must be a city")
  end
end
