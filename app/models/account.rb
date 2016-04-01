class Account < ApplicationRecord
  # Include devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable

  # Attributes

  # The next stage of the onboarding survey that this account needs to complete:
  enum onboarding_stage: {
    travel_plans:            0,
    passengers:              1,
    spending:                2,
    main_passenger_cards:    3,
    companion_cards:         4,
    main_passenger_balances: 5,
    companion_balances:      6,
    readiness:               7,
    # This status means they've fully completed the onboarding survey:
    onboarded:               8,
  }

  def admin; false; end
  alias_method :admin?, :admin

  def has_companion
    !!companion.try(:persisted?)
  end
  alias_attribute :has_companion?, :has_companion

  with_options prefix: true, allow_nil: true do
    delegate :full_name, to: :main_passenger
    delegate :full_name, to: :companion
  end

  def time_zone_name
    if time_zone?
      ActiveSupport::TimeZone.new(time_zone).to_s
    else
      "Unknown"
    end
  end

  def shared_spending
    # To eliminate the need for an extra DB column that will be null most of
    # the time: when spending is shared, it's stored internally under
    # main_passenger.personal_spending, and companion.personal_spending is left
    # blank.
    shares_expenses ?  main_passenger.personal_spending : nil
  end

  # Validations

  validates :time_zone, presence: { unless: "travel_plans? || passengers?" }

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
