class Offer < ApplicationRecord
  # Attributes

  # 'spend' = the minimum amount that the person has to spend using the card
  #           to get the bonus (not relevant for 'on approval' cards)
  # 'cost'  = the card's annual fee
  # 'link'  = the link to the page where people can sign up for the cards.
  #           NOTE: any links from our app to the card application page MUST be
  #           nofollowed, for compliance reasons.

  # condition = what does the customer have to do to receive the points?
  CONDITIONS = {
    'on_minimum_spend' =>  0, # points awarded if you spend $X within Y days
    'on_approval' =>       1, # points awarded as soon as approved for card
    'on_first_purchase' => 2, # points awarded once you make 1st purchase with card
  }.freeze
  enum condition: CONDITIONS

  # TODO add 'none' as a partner
  PARTNERS = {
    'card_ratings' => 0,
    'credit_cards' => 1,
    'award_wallet' => 2,
    'card_benefit' => 3,
  }.freeze
  enum partner: PARTNERS

  # Validations

  # TODO validate that only one offer per product_id can be 'dummy'

  # Associations

  belongs_to :product, class_name: 'CardProduct'
  has_many :cards

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
