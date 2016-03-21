class Account < ApplicationRecord
  # Include devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable

  # Attributes

  # The next stage of the onboarding survey that this account needs to complete:
  enum onboarding_stage: [
    :passengers,
    :spending,
    :main_passenger_cards,
    :companion_cards,
    :main_passenger_balances,
    :companion_balances,
    :onboarded
  ]

  delegate :full_name, to: :main_passenger, prefix: true, allow_nil: true
  delegate :full_name, to: :companion, prefix: true, allow_nil: true

  def admin; false; end
  alias_method :admin?, :admin

  def has_companion
    !!companion.try(:persisted?)
  end
  alias_attribute :has_companion?, :has_companion

  delegate :full_name, to: :main_passenger, prefix: true, allow_nil: true
  delegate :full_name, to: :companion, prefix: true, allow_nil: true

  def shared_spending
    # To eliminate the need for an extra DB column that will be null most of
    # the time: when spending is shared, it's stored internally under
    # main_passenger.personal_spending, and companion.personal_spending is left
    # blank.
    shares_expenses ?  main_passenger.personal_spending : nil
  end

  # Validations

  # Associations

  has_many :travel_plans

  has_many :passengers
  has_one :main_passenger, -> { main }, class_name: "Passenger"
  has_one :companion, -> { companion }, class_name: "Passenger"

  has_one :main_passenger_spending_info,
            through: :main_passenger, source: :spending_info
  has_one :companion_spending_info,
            through: :main_passenger, source: :spending_info

  accepts_nested_attributes_for :main_passenger
  accepts_nested_attributes_for :companion

  # Scopes

end
