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
    onboarded_travel_plans? && onboarded_type? && people.any? && people.all?(&:onboarded?)
  end

  # NOTE: the 'onboarded_travel_plans' column will be set to true when the user
  # completes the 'add travel plan' part of the onboarding survey. Originally,
  # we didn't have a separate column, and looked at the account's associated
  # travel plans to see if they'd added any. (i.e. 'onboarded_travel_plans' was
  # considered true `if account.travel_plans.any?`, without an extra DB column
  # to store it explicitly. However, this had a flaw: if a user completed the
  # onboarding survey, then later on *deleted* their travel plans, they would
  # no longer be considered onboarded, even though they should have been.  So
  # now the onboarded-ness of travel plans is stored in a separate DB column.

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

  has_many :notifications, dependent: :destroy
  has_many :unseen_notifications, -> { unseen }, class_name: "Notification" do
    def count
      proxy_association.owner.unseen_notifications_count
    end
  end

  # TODO these methods don't belong in here; updating the counter cache is a
  # responsibility of the Notification class, not the Account class
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
