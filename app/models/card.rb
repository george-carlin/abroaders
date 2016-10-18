class Card < ApplicationRecord
  self.inheritance_column = :_no_sti

  # Attributes

  enum bp: [:business, :personal]

  enum network: {
    unknown_network: 0,
    visa:            1,
    mastercard:      2,
    amex:            3,
  }
  enum type: {
    unknown_type: 0, # can't use 'unknown' as that's already used by 'network'
    credit:  1,
    charge:  2,
    debit:   3,
  }

  concerning :Image do
    included do
      # Standard credit card dimensions are 85.60*53.98mm, which gives the
      # following aspect ratio:
      ASPECT_RATIO = 1.586

      has_attached_file :image, styles: {
        large:  "350x#{350 / ASPECT_RATIO}>",
        medium: "210x#{210 / ASPECT_RATIO}>",
        small:  "140x#{140 / ASPECT_RATIO}>",
      }, default_url: "/images/:style/missing.png"
      validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
      validates_attachment_presence :image
    end
  end

  concerning :Survey do
    def not_on_survey
      !shown_on_survey
    end

    included do
      scope :survey, -> { where(shown_on_survey: true) }
    end
  end

  belongs_to_fake_db_model :bank
  delegate :name, to: :bank, prefix: true

  # A number which uniquely identifies both which bank this card belongs to,
  # and whether it is a business card or a personal one. Displaying this in
  # the interface allows the admin to determine these things about the card
  # at a glance.
  #
  # The bank number is determined by the bank_id. bank_id is always an odd number.
  # If this is a personal card, bank_number is equal to bank_id. If this is
  # a business card, bank_number is equal to bank_id  1.
  #
  # (This numbering system is a legacy thing from before the app existed, when
  # we still doing everything through Fieldbook, Infusionsoft etc.)
  def bank_number
    raise "can't determine bank number without bank" unless bank.present?
    raise "can't determine bank number without B/P"  unless bp.present?
    personal? ? bank.id : bank.id + 1
  end

  # A short string that allows the admin to quickly identify the card.
  # Format: AA-BBB-C.
  # A: bank_number. An integer.
  # B: code - a 2-4 letter user-chosen string
  # C: if network is unknown, then '?'. Else 'A', 'M', or 'V', for Amex,
  #    MasterCard, or Visa respectively
  def identifier
    unless bank && bp && code && network
      raise "can't generate an identifier unless bank, bp, code, and network are all present"
    end
    [
      "%.2d" % bank_number,
      code,
      unknown_network? ? "?" : network.upcase[0],
    ].join("-")
  end

  def annual_fee
    annual_fee_cents / 100.0 if annual_fee_cents.present?
  end

  def annual_fee=(annual_fee_dollars)
    self.annual_fee_cents = (annual_fee_dollars.to_i * 100).to_i
  end

  # Validations

  validates :code, format: {
    message: "must consist only of capital letters and be 2-4 letters long",
    with: /\A[A-Z]{2,4}\z/,
  }
  with_options presence: true do
    validates :annual_fee_cents
    validates :bank_id
    validates :bp
    validates :name
    validates :network
    validates :type
  end

  # Associations

  has_many :offers
  has_many :accounts, class_name: "CardAccount"
  belongs_to :currency

  # Callbacks

  auto_strip_attributes :code, :name, callback: :before_validation
end
