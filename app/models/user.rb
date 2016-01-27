class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable

  # Attributes

  delegate(
    *(UserInfo.column_names - %w[id user_id created_at updated_at] +
      %w[whatsapp? text_message? imessage? has_business?
          has_business_with_ein?  has_business_without_ein?]),
    to: :info, allow_nil: true
  )

  def name
    info.present? ? info.full_name : "#{self.class} ##{id}"
  end

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
