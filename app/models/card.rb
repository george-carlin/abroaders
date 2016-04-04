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
  enum type: [:credit, :charge, :debit]

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
  
  validates :identifier, presence: true, uniqueness: true
  validates :name, presence: true
  validates :network, presence: true
  validates :bp, presence: true
  validates :type, presence: true
  validates :annual_fee_cents, presence: true
  validates :currency, presence: true

  # Associations

  # has_many :offers,   class_name: "CardOffer"
  # has_many :accounts, class_name: "CardAccount"
  belongs_to :currency

  # Scopes

  scope :inactive, -> { where(active: false) }

end
