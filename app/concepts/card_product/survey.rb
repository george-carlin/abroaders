class CardProduct < ApplicationRecord
  # TODO delete me, use Reform
  class Survey < ApplicationForm
    attribute :person, Person
    # TODO keep this consistent with other form objects and call the attribute
    # 'card_ids'
    attribute :cards, Array

    def each_section
      CardProduct.survey.group_by(&:bank).each do |bank, products|
        yield bank, products.group_by(&:bp)
      end
    end

    private

    def persist!
      cards.each do |card|
        # Example hash contents: {
        #   product_id: '3'
        #   opened: 'true'
        #   opened_at_(1i): '2016'
        #   opened_at_(2i): '1'
        #   closed: 'true'
        #   closed_at_(1i): '2016'
        #   closed_at_(2i): '1'
        # }
        #
        # Note that 'opened' and 'closed' will be nil, not false or 'false', if
        # the value is false.
        #
        next unless card['opened'].present?

        opened_at_y = card['opened_at_(1i)'].to_i
        opened_at_m = card['opened_at_(2i)'].to_i

        attributes = {
          product: CardProduct.survey.find(card['product_id']),
          opened_at: Date.new(opened_at_y, opened_at_m),
        }

        if card["closed"].present?
          closed_at_y = card["closed_at_(1i)"].to_i
          closed_at_m = card["closed_at_(2i)"].to_i
          attributes["closed_at"] = Date.new(closed_at_y, closed_at_m)
        end

        person.cards.from_survey.create!(attributes)
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
