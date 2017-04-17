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
  has_many :actionable_card_recommendations, through: :people
  has_many :unresolved_card_recommendations, through: :people

  def actionable_card_recommendations?
    actionable_card_recommendations.any?
  end

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

  def people_by_type(person_type)
    if !couples? && %w[companion both].include?(person_type)
      raise ArgumentError, "can't find '#{person_type}' for couples account"
    end

    case person_type
    when 'both'
      people.to_a.sort_by(&:type).reverse # owner first
    when 'owner'
      [owner]
    when 'companion'
      [companion]
    else
      raise ArgumentError, "unrecognised person type '#{person_type}'"
    end
  end

  # admins can't edit notes, so our crude way of allowing it for now
  # is to let admins submit a new updated note, and we only ever show
  # the most recent note to the user:
  def recommendation_note
    recommendation_notes.order(created_at: :desc).first
  end

  has_and_belongs_to_many :home_airports,
                          class_name: "Airport",
                          join_table: :accounts_home_airports,
                          association_foreign_key: :airport_id

  has_many :interest_regions, dependent: :destroy
  has_many :regions_of_interest, through: :interest_regions, source: :region

  has_many :recommendation_requests, through: :people
  has_many :resolved_recommendation_requests, through: :people
  has_many :unresolved_recommendation_requests, through: :people

  def unresolved_recommendation_requests?
    unresolved_recommendation_requests.any?
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
