class CardOffer < ApplicationRecord

  # Attributes

  enum status: [:live, :expired]

  delegate :name, to: :card, prefix: true
  delegate :bank_name, to: :card

  # Validations

  with_options presence: true do
    validates :identifier, uniqueness: true
    validates :status

    with_options numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE } do
      validates :cost
      validates :days
      validates :points_awarded
      validates :spend
    end
  end

  # Associations

  belongs_to :card

end
