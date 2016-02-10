class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable

  # Attributes

  delegate :business_spending, :citizenship, :credit_score, :first_name,
      :full_name, :has_business, :has_business?, :has_business_with_ein?,
      :has_business_without_ein?, :has_completed_card_survey,
      :has_completed_card_survey?, :has_completed_cards_survey,
      :has_completed_cards_survey?, :imessage, :imessage?, :last_name,
      :middle_names, :personal_spending, :phone_number, :text_message,
      :text_message?, :time_zone, :whatsapp, :whatsapp?, :will_apply_for_loan,
    to: :info, allow_nil: true

  def name
    info.present? ? info.full_name : "#{self.class} ##{id}"
  end

  def has_completed_user_info_survey?
    !!info.try(:persisted?)
  end

  def has_completed_onboarding_survey?
    info.present? && info.persisted? && info.has_completed_card_survey?
  end

  # Validations

  validates :info, associated: true

  # Associations

  has_many :card_accounts
  has_many :card_recommendations, -> { recommendations },
                                  class_name: "CardAccount"
  has_many :cards, through: :card_accounts
  has_many :travel_plans

  has_one :info, class_name: "UserInfo"

  has_many :balances
  has_many :currencies, through: :balances

  # Scopes

  scope :admin, -> { where(admin: true) }
  scope :non_admin, -> { where(admin: false) }
end
