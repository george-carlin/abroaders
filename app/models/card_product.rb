# A brand of Card offered by a particular bank, e.g. "Chase Sapphire". A
# specific instance of a card owned owned by a particular person (i.e. the one
# physical copy of a Chase Sapphire card which you keep in your wallet, as
# opposed to the general concept of a Chase Sapphire card), is represented by
# the Card model (which we plan on eventually renaming to just 'card')
class CardProduct < ApplicationRecord
  self.inheritance_column = :_no_sti

  # Attributes

  enum bp: [:business, :personal]

  enum network: {
    # can't call this 'unknown' as that would conflict with types
    unknown_network: 0,
    visa:            1,
    mastercard:      2,
    amex:            3,
  }
  enum type: {
    # can't call this 'unknown' as that would conflict with networks
    unknown_type: 0,
    credit:  1,
    charge:  2,
    debit:   3,
  }

  # Standard credit card dimensions are 85.60*53.98mm, which gives the
  # following aspect ratio:
  IMAGE_ASPECT_RATIO = 1.586

  has_attached_file :image, styles: {
    large:  "350x#{350 / IMAGE_ASPECT_RATIO}>",
    medium: "210x#{210 / IMAGE_ASPECT_RATIO}>",
    small:  "140x#{140 / IMAGE_ASPECT_RATIO}>",
  }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
  validates_attachment_presence :image

  delegate :name, to: :currency, prefix: true
  delegate :name, to: :bank, prefix: true

  def annual_fee
    annual_fee_cents / 100.0 unless annual_fee_cents.nil?
  end

  def annual_fee=(annual_fee_dollars)
    self.annual_fee_cents = (annual_fee_dollars.to_f * 100).round.to_i
  end

  # Validations

  with_options presence: true do
    validates :annual_fee_cents
    validates :bank_id
    validates :bp
    validates :name
    validates :network
    validates :type
  end

  # Associations

  has_many :offers, foreign_key: :product_id
  has_many :recommendable_offers, -> { recommendable }, class_name: 'Offer', foreign_key: :product_id
  has_many :cards
  belongs_to :currency
  belongs_to :bank

  # Scopes

  scope :survey, -> { where(shown_on_survey: true) }
  scope :recommendable, -> { joins(:recommendable_offers).distinct }

  # Callbacks

  auto_strip_attributes :name, callback: :before_validation
end
