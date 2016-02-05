class Card < ApplicationRecord
   self.inheritance_column = :_no_sti

  # Attributes

  enum bank: %i[chase citibank american_express barclays capital_one
                us_bank bank_of_america]
  enum bp: [:business, :personal]
  enum brand: [:visa, :mastercard, :amex]
  enum type: [:credit, :charge, :debit]

  def inactive
    !active
  end
  alias_method :inactive?, :inactive

  def bank_name
    BankName.new(bank).name
  end

  def full_name
    # Call them all 'Chase' cards until we've added Banks
    "#{identifier} - Chase - #{name}"
  end

  def annual_fee
    annual_fee_cents / 100.0 if annual_fee_cents.present?
  end

  def annual_fee=(annual_fee_dollars)
    self.annual_fee_cents = (annual_fee_dollars.to_i * 100).to_i
  end

  def currency
    Currency.new(currency_id)
  end

  # Validations
  
  validates :identifier, presence: true, uniqueness: true
  validates :name, presence: true
  validates :brand, presence: true
  validates :bp, presence: true
  validates :type, presence: true
  validates :annual_fee_cents, presence: true
  validates :currency_id,
    inclusion: { allow_nil: true, in: Currency.keys },
    presence: true

  # Associations

  # has_many :offers,   class_name: "CardOffer"
  # has_many :accounts, class_name: "CardAccount"

  # Scopes

  scope :inactive, -> { where(active: false) }

end
