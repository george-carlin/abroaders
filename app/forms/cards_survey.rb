class CardsSurvey < Form

  attr_accessor :person

  def initialize(person)
    self.person = person
  end

  def assign_attributes(attributes)
    @card_ids = attributes.fetch(:card_ids)
  end

  def save
    super do
      CardAccount.unknown.create!(
        Card.survey.where(id: @card_ids).find_each.map do |card|
          { person: person, card: card }
        end
      )
    end
  end

end
