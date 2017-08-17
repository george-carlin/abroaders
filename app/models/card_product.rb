# A brand of Card offered by a particular bank, e.g. "Chase Sapphire". A
# specific instance of a card owned owned by a particular person (i.e. the one
# physical copy of a Chase Sapphire card which you keep in your wallet, as
# opposed to the general concept of a Chase Sapphire card), is represented by
# the Card model (which we plan on eventually renaming to just 'card')
class CardProduct < ApplicationRecord
  self.inheritance_column = :_no_sti

  # Attributes

  def business
    !personal
  end
  alias business? business

  def business=(bool)
    self.personal = !bool
  end

  def bp
    personal ? 'personal' : 'business'
  end

  Network = Types::Strict::String.enum('unknown', 'visa', 'mastercard', 'amex', 'discover')
  Type = Types::Strict::String.enum('unknown', 'credit', 'charge', 'debit')

  attribute_type :network, Network
  attribute_type :type, Type

  # Standard credit card dimensions are 85.60*53.98mm, which gives the
  # following aspect ratio:
  IMAGE_ASPECT_RATIO = 1.586

  has_attached_file :image, styles: {
    large:  "350x#{350 / IMAGE_ASPECT_RATIO}>",
    medium: "210x#{210 / IMAGE_ASPECT_RATIO}>",
    small:  "140x#{140 / IMAGE_ASPECT_RATIO}>",
  }
  # file validations are handled in the form object (using the file_validators
  # gem), but Paperclip requires us to explicitly state that there are no
  # validations in the model layer
  do_not_validate_attachment_file_type :image

  delegate :name, to: :currency, prefix: true, allow_nil: true
  delegate :name, to: :bank, prefix: true

  def annual_fee
    annual_fee_cents / 100.0 unless annual_fee_cents.nil?
  end

  def annual_fee=(annual_fee_dollars)
    self.annual_fee_cents = (annual_fee_dollars.to_f * 100).round
  end

  # Associations

  has_many :offers
  has_many :recommendable_offers, -> { recommendable }, class_name: 'Offer'
  has_many :cards
  belongs_to :currency

  def bank
    return nil if bank_id.nil?
    @bank ||= Bank.find(bank_id)
  end

  def bank=(new_bank)
    raise unless new_bank.is_a?(Bank)
    self.bank_id = new_bank.id
    @bank = new_bank
  end

  def bank_id=(new_bank_id)
    @bank = nil unless @bank && @bank.id == new_bank_id
    super
  end

  def reload
    @bank = nil
    super
  end

  # Scopes

  scope :survey, -> { where(shown_on_survey: true) }
  scope :recommendable, -> { joins(:recommendable_offers).distinct }

  scope :business, -> { where(personal: false) }
  scope :personal, -> { where(personal: true) }

  # Callbacks

  after_initialize { self.personal = true if personal.nil? } # set default
end
