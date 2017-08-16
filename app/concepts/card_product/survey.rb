class CardProduct < CardProduct.superclass
  # TODO delete me, use Reform
  class Survey < ApplicationForm
    attribute :person, Person
    # TODO keep this consistent with other form objects and call the attribute
    # 'card_ids'
    attribute :cards, Array

    private

    def persist!
      cards.each do |card|
        # Example hash contents: {
        #   product_id: '3'
        #   opened: 'true'
        #   opened_on_(1i): '2016'
        #   opened_on_(2i): '1'
        #   closed: 'true'
        #   closed_on_(1i): '2016'
        #   closed_on_(2i): '1'
        # }
        #
        # Note that 'opened' and 'closed' will be nil, not false or 'false', if
        # the value is false.
        #
        next unless card['opened'].present?

        opened_on_y = card['opened_on_(1i)'].to_i
        opened_on_m = card['opened_on_(2i)'].to_i

        attributes = {
          card_product: CardProduct.survey.find(card['product_id']),
          opened_on: Date.new(opened_on_y, opened_on_m),
        }

        if card["closed"].present?
          closed_on_y = card["closed_on_(1i)"].to_i
          closed_on_m = card["closed_on_(2i)"].to_i
          attributes["closed_on"] = Date.new(closed_on_y, closed_on_m)
        end

        person.cards.create!(attributes)
      end

      onboarder = Account::Onboarder.new(person.account)
      if person.owner?
        onboarder.add_owner_cards!
      else
        onboarder.add_companion_cards!
      end
    end
  end
end
