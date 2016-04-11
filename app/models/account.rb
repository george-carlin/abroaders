class Account < ApplicationRecord
  # Include devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable

  # Attributes

  def has_companion
    !!companion.try(:persisted?)
  end
  alias_attribute :has_companion?, :has_companion

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

  has_many :people
  has_one :main_passenger, -> { main }, class_name: "Person"
  has_one :companion, -> { companion }, class_name: "Person"

  has_one :main_passenger_spending_info,
            through: :main_passenger, source: :spending_info
  has_one :companion_spending_info,
            through: :main_passenger, source: :spending_info

  accepts_nested_attributes_for :main_passenger
  accepts_nested_attributes_for :companion

  # Callbacks

  # The uniqueness validation on #email assumes that all email are lowercase -
  # so make sure that they actually are lowercase, or bad things will happen
  before_save { self.email = email.downcase if email.present? }

  # Scopes

end
