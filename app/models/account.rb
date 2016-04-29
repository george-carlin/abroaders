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
    onboarded_type? && people.all?(&:onboarded?)
  end

  # Temporary solution to let admins see who has been recommended a card and
  # who hasn't
  def last_recommendation_at
    people.joins(:card_recommendations).maximum('"card_accounts"."created_at"')
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
