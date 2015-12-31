class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable

  # Validations

  validates :name, presence: true

  # Associations

  has_many :card_accounts
  has_many :cards, through: :card_accounts

  # Scopes

  scope :admin, -> { where(admin: true) }
  scope :non_admin, -> { where(admin: false) }
end
