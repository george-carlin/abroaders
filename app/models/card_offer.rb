class CardOffer < ApplicationRecord

  # Attributes

  enum status: [:live, :expired]

  # condition = what does the customer have to do to receive the points?
  enum condition: {
    on_minimum_spend:  0, # points awarded if you spend $X within Y days
    on_approval:       1, # points awarded as soon as approved for card
    on_first_purchase: 2, # points awarded once you make 1st purchase with card
  }

  delegate :name, to: :card, prefix: true
  delegate :bank_name, to: :card

  def full_identifier
    "#{card.identifier}-#{identifier}"
  end

  # A shorthand code that identifies the offer based on the points awarded,
  # minimum spend, and days. Note that this isn't necessarily unique per offer.
  def identifier
    [ # Show points and spend as multiples of 1000, but don't print the decimal
      # point if it's an exact multiple:
      (points_awarded / 1000.0).to_s.sub(/\.0+\z/, ''),
      (spend / 1000.0).to_s.sub(/\.0+\z/, ''),
      days,
    ].join("/")
    # Note - we might eventually want to add a unique code per affiliate
    # to the end of this identifier.
  end

  # Validations

  with_options presence: true do
    validates :status
    validates :link # TODO validate it looks like a valid link

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
