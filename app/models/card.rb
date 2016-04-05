class Card < ApplicationRecord
  self.inheritance_column = :_no_sti

  # Attributes

  enum bp: [:business, :personal]
  enum network: {
    unknown:    0,
    visa:       1,
    mastercard: 2,
    amex:       3,
  }
  enum type: {
    unidentified: 0, # can't use 'unknown' as that's already used by 'network'
    credit:  1,
    charge:  2,
    debit:   3,
  }

  def inactive
    !active
  end
  alias_method :inactive?, :inactive

  # Don't call this 'Bank' because that would clash with '::Bank'
  concerning :Banks do
    included do
      delegate :name, to: :bank, prefix: true
    end

    def bank
      @bank ||= Bank.new(bank_id)
    end

    def bank_id=(bank_id)
      @bank = nil
      super
    end
  end


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
      network == "unknown" ? "?" : network.upcase[0]
    ].join("-")
  end

  def full_name
    "TODO - complete Card#full_name method"
  end

  def annual_fee
    annual_fee_cents / 100.0 if annual_fee_cents.present?
  end

  def annual_fee=(annual_fee_dollars)
    self.annual_fee_cents = (annual_fee_dollars.to_i * 100).to_i
  end

  # Validations
  
  validates :code, format: { with: /\A[A-Z]{2,4}\z/, message: "must be 2-4 capital letters" }
  with_options presence: true do
    validates :annual_fee_cents
    validates :bp
    validates :currency
    validates :name
    validates :network
    validates :type
  end

  # Associations

  # has_many :offers,   class_name: "CardOffer"
  # has_many :accounts, class_name: "CardAccount"
  belongs_to :currency

  # Scopes

  scope :inactive, -> { where(active: false) }

end
