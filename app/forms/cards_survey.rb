class CardsSurvey < ApplicationForm

  attr_accessor :person

  def initialize(attributes={})
    @available_cards = Card.survey
    assign_attributes(attributes)
    @cards = {}
  end

  def assign_attributes(attributes)
    attributes.stringify_keys!
    @person = attributes["person"]
    @card_accounts = attributes.fetch("card_accounts", [])
  end

  def each_section
    @available_cards.group_by(&:bank).each do |bank, cards|
      yield bank, cards.group_by(&:bp)
    end
  end

  def save
    super do
      @card_accounts.each do |card_account|
        # Example hash contents: {
        #   card_id: '3'
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
        next unless card_account["opened"].present?

        opened_at_y = card_account["opened_at_(1i)"]
        opened_at_m = card_account["opened_at_(2i)"]

        attributes = {
          card: Card.survey.find(card_account["card_id"]),
          opened_at: "#{opened_at_y}-#{opened_at_m}-01",
        }

        if card_account["closed"].present?
          closed_at_y = card_account["closed_at_(1i)"]
          closed_at_m = card_account["closed_at_(2i)"]
          attributes["closed_at"] = "#{closed_at_y}-#{closed_at_m}-01"
          attributes["status"] = "closed"
        else
          attributes["status"] = "open"
        end

        @person.card_accounts.from_survey.create!(attributes)
      end
      person.update_attributes!(onboarded_cards: true)
    end
  end
end
