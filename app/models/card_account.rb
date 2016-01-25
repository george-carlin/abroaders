class CardAccount < ApplicationRecord

  # Attributes

  include Statuses

  delegate :brand, :type, :bp, :name, :identifier, :bank_name, to: :card,
    prefix: true

  # Validations

  validates :card, presence: true
  validates :user, presence: true
  validates :status, presence: true

  # Associations

  belongs_to :card
  belongs_to :user

end
