class Offer < ApplicationRecord

  # Attributes

  # 'spend' = the minimum amount that the person has to spend using the card
  #           to get the bonus (not relevant for 'on approval' cards)
  # 'cost'  = the card's annual fee
  # 'link'  = the link to the page where people can sign up for the cards.
  #           NOTE: any links from our app to the card application page MUST be
  #           nofollowed, for compliance reasons.

  # condition = what does the customer have to do to receive the points?
  enum condition: {
    on_minimum_spend:  0, # points awarded if you spend $X within Y days
    on_approval:       1, # points awarded as soon as approved for card
    on_first_purchase: 2, # points awarded once you make 1st purchase with card
  }

  enum partner: {
    card_ratings: 0,
    credit_cards: 1,
    award_wallet: 2,
    card_benefit: 3,
  }

  # TODO move me to presenter
  delegate :name, :identifier, to: :card, prefix: true
  delegate :bank_name, to: :card

  # Validations

  with_options presence: true do
    validates :link # TODO validate it looks like a valid link
    validates :partner, inclusion: { in: Offer.partners.keys }, allow_blank: true

    with_options numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE } do
      validates :cost
      validates :days, unless: :on_approval?
      validates :points_awarded
      validates :spend, if: :on_minimum_spend?
    end
  end

  # Associations

  belongs_to :card
  has_many :card_accounts, foreign_key: :offer_id

  # Callbacks

  before_save :nullify_irrelevant_columns

  # Methods

  def live?
    killed_at.nil?
  end

  def dead?
    !killed_at.nil?
  end

  private

  def nullify_irrelevant_columns
    self.days  = nil if on_approval?
    self.spend = nil unless on_minimum_spend?
  end

  # Scopes

  scope :live, -> { where(killed_at: nil) }
  scope :dead, -> { where.not(killed_at: nil) }
end
