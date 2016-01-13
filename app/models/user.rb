class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable

  # Attributes

  delegate :full_name, to: :contact_info, allow_nil: true

  # Validations

  # Associations

  has_many :card_accounts
  has_many :cards, through: :card_accounts
  has_many :travel_plans

  has_one :contact_info
  has_one :spending_info

  # Scopes

  scope :admin, -> { where(admin: true) }
  scope :non_admin, -> { where(admin: false) }
end
