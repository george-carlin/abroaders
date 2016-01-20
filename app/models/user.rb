class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable

  # Attributes

  delegate :full_name, :first_name, :middle_names, :last_name, :phone_number,
    :whatsapp, :text_message, :imessage, :time_zone, :citizenship,
    :credit_score, :will_apply_for_loan, :spending_per_month_dollars,
    :has_business,
    to: :info, allow_nil: true

  # Validations

  # Associations

  has_many :card_accounts
  has_many :cards, through: :card_accounts
  has_many :travel_plans

  has_one :info, class_name: "UserInfo"

  # Scopes

  scope :admin, -> { where(admin: true) }
  scope :non_admin, -> { where(admin: false) }
end
