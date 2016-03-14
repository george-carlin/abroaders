class Passenger < ApplicationRecord

  # Attributes

  enum citizenship:  [ :us_citizen, :us_permanent_resident, :neither]

  def full_name
    [first_name, middle_names, last_name].compact.join(" ")
  end

  def complete?
    persisted? && has_added_cards? && has_added_balances?
  end

  alias_attribute :main_passenger?, :main

  def companion?
    !main?
  end

  # Validations

  validates :account, presence: true, uniqueness: { scope: :main }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true

  # Associations

  belongs_to :account
  has_one :spending_info

  # Callbacks

  auto_strip_attributes :first_name, :middle_names, :last_name, :phone_number

  # Scopes

  scope :main,      -> { where(main: true) }
  scope :companion, -> { where(main: false) }

end
