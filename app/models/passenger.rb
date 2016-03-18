class Passenger < ApplicationRecord

  # Attributes

  enum citizenship:  [ :us_citizen, :us_permanent_resident, :neither]

  def full_name
    [first_name, middle_names, last_name].compact.join(" ")
  end

  alias_attribute :main_passenger?, :main

  def companion?
    !main?
  end

  # Validations

  validates :account, uniqueness: { scope: :main }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true

  # Associations

  belongs_to :account
  has_one :spending_info, dependent: :destroy

  has_many :card_accounts
  has_many :card_recommendations, -> { recommendations },
                                  class_name: "CardAccount"
  has_many :cards, through: :card_accounts

  has_many :balances
  has_many :currencies, through: :balances

  # Callbacks

  auto_strip_attributes :first_name, :middle_names, :last_name, :phone_number

  # Scopes

  scope :main,      -> { where(main: true) }
  scope :companion, -> { where(main: false) }

end
