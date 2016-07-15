# This works with both Accounts and Persons (both respond to card_accounts).
# Pass it an Account and you can then delegate to the card accounts of the
# Account's people.
class CardAccountsPresenter < ApplicationPresenter

  delegate :from_survey, to: :card_accounts, prefix: true

  # --- Methods only relevant when model is an Account ---

  %i[owner partner].each do |method|
    define_method method do
      self.class.new(super(), view)
    end
  end

  # --- Methods only relevant when model is a Person: ---

  def subheading
    "#{first_name}'s Cards"
  end

  def recommendations
    card_accounts.recommendations.
      includes(offer: { card: :currency }).
      # excluding declined accounts is a temp solution until we decide how we're
      # going to display declined cards. the 'recommendations' scope should
      # probably be replaced with something more specific:
      where(declined_at: nil)
  end

  def no_card_accounts_from_survey
    "#{first_name} has no other cards"
  end

  private

  def card_accounts
    @card_accounts ||= model.card_accounts.includes(:card).order(:created_at)
  end

end
