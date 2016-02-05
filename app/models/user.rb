class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable

  # Attributes

  delegate :business_spending, :citizenship, :credit_score, :first_name,
      :full_name, :has_business, :has_business?, :has_business_with_ein?,
      :has_business_without_ein?, :imessage, :imessage?, :last_name,
      :middle_names, :personal_spending, :phone_number, :text_message,
      :text_message?, :time_zone, :whatsapp,  :whatsapp?, :will_apply_for_loan,
    to: :info, allow_nil: true

  def name
    info.present? ? info.full_name : "#{self.class} ##{id}"
  end

  # Validations

  # Associations

  has_many :card_accounts
  has_many :card_recommendations, -> { recommendations },
                                  class_name: "CardAccount"
  has_many :cards, through: :card_accounts
  has_many :travel_plans

  has_one :info, class_name: "UserInfo"

  # Scopes

  scope :admin, -> { where(admin: true) }
  scope :non_admin, -> { where(admin: false) }
end
