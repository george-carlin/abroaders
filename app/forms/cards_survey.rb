class CardsSurvey < Form

  attr_accessor :passenger

  def initialize(passenger)
    self.passenger = passenger
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
      passenger.update_attributes!(has_added_cards: true)
    end
  end

end
