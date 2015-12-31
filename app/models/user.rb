class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable

  validates :name, presence: true

  # Scopes

  scope :admin, -> { where(admin: true) }
  scope :non_admin, -> { where(admin: false) }
end
