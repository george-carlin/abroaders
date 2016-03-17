class CardsSurvey < Form

  attr_accessor :passenger

  def initialize(passenger)
    self.passenger = passenger
    raise_unless_at_correct_onboarding_stage!
  end

  def assign_attributes(attributes)
    @card_ids = attributes.fetch(:card_ids)
  end

  def save
    super do
      CardAccount.unknown.create!(
        Card.where(id: @card_ids).find_each.map do |card|
          { passenger: passenger, card: card }
        end
      )
      passenger.account.update_attributes!(onboarding_stage: next_stage)
    end
  end

  private

  # Sanity check to make sure we're at the right stage of the survey:
  def raise_unless_at_correct_onboarding_stage!
    if passenger.main?
      raise unless passenger.account.onboarding_stage == "main_passenger_cards"
    else
      raise unless passenger.account.onboarding_stage == "companion_cards"
    end
  end

  def next_stage
    if passenger.main? && passenger.account.has_companion?
      "companion_cards"
    else
      "main_passenger_balances"
    end
  end

end
