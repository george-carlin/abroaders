class ContactInfo < ApplicationRecord

  # Validations

  validates :user, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true

  # Associations

  belongs_to :user
end
