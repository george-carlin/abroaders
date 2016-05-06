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

  # TODO move away from 'passenger' and 'companion' terminology.
  alias_method :main_person, :main_passenger
  alias_method :partner, :companion

  has_many :card_accounts, through: :people
  has_many :card_recommendations, through: :people
  has_many :cards, through: :card_accounts

  has_one :main_passenger_spending_info,
            through: :main_passenger, source: :spending_info
  has_one :companion_spending_info,
            through: :main_passenger, source: :spending_info

  # TODO are these still necessary?
  accepts_nested_attributes_for :main_passenger
  accepts_nested_attributes_for :companion

  has_many :notifications
  has_many :unseen_notifications, -> { unseen }, class_name: "Notification" do
    def count
      proxy_association.owner.unseen_notifications_count
    end
  end

  def increment_unseen_notifications_count
    self.class.increment_counter(:unseen_notifications_count, id)
  end

  def decrement_unseen_notifications_count
    self.class.decrement_counter(:unseen_notifications_count, id)
  end

  # Callbacks

  # The uniqueness validation on #email assumes that all email are lowercase -
  # so make sure that they actually are lowercase, or bad things will happen
  before_save { self.email = email.downcase if email.present? }

  # Scopes

end
