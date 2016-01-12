class ContactInfo < ApplicationRecord

  # Attributes

  def full_name
    [first_name, middle_names, last_name].compact.join(" ")
  end

  # Validations

  validates :user, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true
  validates :time_zone, presence: true

  # Associations

  belongs_to :user
end
