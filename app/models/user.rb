class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable

  # Validations

  # Associations

  has_many :card_accounts
  has_many :cards, through: :card_accounts

  has_one :contact_info

  # Scopes

  scope :admin, -> { where(admin: true) }
  scope :non_admin, -> { where(admin: false) }
end
