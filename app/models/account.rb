class Account < ApplicationRecord
  # Include devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable

  # Attributes

  def has_companion
    !!companion.try(:persisted?)
  end
  alias_attribute :has_companion?, :has_companion

  def onboarded?
    people.all?(&:onboarded?)
  end

  # The way the onboarding survey currently works, we know they've completed
  # the 'account type' survey if monthly_spending_usd is not nil, even though
  # the two 'attributes' aren't really logically related. In future if the way
  # the survey changes we may need to change things to add a boolean DB column
  # to store 'onboarded_account_type' in its own seperate place.
  def onboarded_account_type?
    monthly_spending_usd.present?
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
