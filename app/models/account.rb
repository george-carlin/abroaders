class Account < ApplicationRecord
  # Include devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable

  # Attributes
  APP_SUMO_PROMO_CODE = 'appsumoAY83ZG'.freeze

  def app_sumo?
    promo_code == APP_SUMO_PROMO_CODE
  end

  def couples?
    !companion.nil?
  end

  def onboarded?
    onboarding_state == "complete"
  end

  def has_any_recommendations?
    people.any? { |person| person.last_recommendations_at.present? }
  end

  # Validations

  # Associations

  has_many :travel_plans

  has_many :people
  has_many :eligible_people, -> { eligible }, class_name: 'Person'
  has_one :owner, -> { owner }, class_name: 'Person'
  has_one :companion, -> { companion }, class_name: 'Person'

  has_one :award_wallet_user
  has_many :award_wallet_owners,   through: :award_wallet_user
  has_many :award_wallet_accounts, through: :award_wallet_owners

  def connected_to_award_wallet?
    award_wallet_user && award_wallet_user.loaded?
  end

  delegate :first_name, to: :owner,     prefix: true
  delegate :first_name, to: :companion, prefix: true

  has_many :cards, through: :people
  has_many :card_accounts, through: :people
  has_many :card_recommendations, through: :people
  has_many :unresolved_card_recommendations, through: :people

  has_many :balances, through: :people

  has_one :phone_number

  has_one :owner_spending_info, through: :owner, source: :spending_info
  has_one :companion_spending_info, through: :owner, source: :spending_info

  has_many :notifications, dependent: :destroy
  has_many :unseen_notifications, -> { unseen }, class_name: "Notification" do
    def count
      proxy_association.owner.unseen_notifications_count
    end
  end

  has_many :recommendation_notes, dependent: :destroy

  has_and_belongs_to_many :home_airports,
                          class_name: "Airport",
                          join_table: :accounts_home_airports,
                          association_foreign_key: :airport_id

  has_many :interest_regions, dependent: :destroy
  has_many :regions_of_interest, through: :interest_regions, source: :region

  has_many :recommendation_requests, through: :people
  has_many :confirmed_recommendation_requests, through: :people
  has_many :unconfirmed_recommendation_requests, through: :people, source: :unconfirmed_recommendation_request

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
