class Account < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable

  # Attributes

  # SURVEYTODO what to do with all of this?
  # delegate :business_spending, :citizenship, :credit_score, :first_name,
  #     :full_name, :has_business, :has_business?, :has_business_with_ein?,
  #     :has_business_without_ein?, :has_added_balances, :has_added_balances?,
  #     :has_added_cards, :has_added_cards?, :imessage, :imessage?, :last_name,
  #     :middle_names, :personal_spending, :phone_number, :text_message,
  #     :text_message?, :time_zone, :whatsapp, :whatsapp?, :will_apply_for_loan,
  #   to: :survey, allow_nil: true

  # def name
  #   survey.present? ? survey.full_name : "#{self.class} ##{id}"
  # end

  def has_added_passengers?
    passengers.any? && passengers.all?(&:persisted?)
  end

  def has_added_spending?
    passengers.any? && passengers.all?(&:has_added_spending?)
  end

  def has_added_cards?
    passengers.any? && passengers.all?(&:has_added_cards?)
  end

  def survey_complete?
    has_added_passengers? && has_added_spending? && has_added_cards? &&
      has_added_balances?
  end

  def has_companion
    !!companion.try(:persisted?)
  end
  alias_attribute :has_companion?, :has_companion

  # Validations

  # validates :survey, associated: true

  # Associations

  has_many :travel_plans

  has_many :passengers
  has_one :main_passenger, -> { main }, class_name: "Passenger"
  has_one :companion, -> { companion }, class_name: "Passenger"

  has_one :main_passenger_spending_info,
            through: :main_passenger, source: :spending_info
  has_one :companion_spending_info,
            through: :main_passenger, source: :spending_info

  has_many :balances
  has_many :currencies, through: :balances

  accepts_nested_attributes_for :main_passenger
  accepts_nested_attributes_for :companion

  # Scopes

  scope :admin, -> { where(admin: true) }
  scope :non_admin, -> { where(admin: false) }

  scope :onboarded, -> do
    non_admin.joins(:survey).where(
      surveys: { has_added_cards: true, has_added_balances: true }
    )
  end
end
