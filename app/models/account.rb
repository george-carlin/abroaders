class Account < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable

  # Attributes

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

  # def has_completed_main_survey?
  #   !!survey.try(:persisted?)
  # end

  def survey_complete?
    # SURVEYTODO
    # !!survey.try(:complete?)
    false
  end

  # Validations

  # validates :survey, associated: true

  # Associations

  has_many :card_accounts
  has_many :card_recommendations, -> { recommendations },
                                  class_name: "CardAccount"
  has_many :cards, through: :card_accounts
  has_many :travel_plans

  has_one :main_passenger, -> { main }, class_name: "Passenger"
  has_one :companion, -> { companion }, class_name: "Passenger"

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
