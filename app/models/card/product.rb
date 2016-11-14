class Card::Product < ApplicationRecord
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

  belongs_to :bank
  delegate :name, to: :bank, prefix: true

  def identifier
    Identifier.new(self)
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

  # Scope

  scope :survey, -> { where(shown_on_survey: true) }

  # Callbacks

  auto_strip_attributes :code, :name, callback: :before_validation

  def serializer_class
    Card::Product::Serializer
  end

  def presenter_class
    Card::Product::Presenter
  end
end
