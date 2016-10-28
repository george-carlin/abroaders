class CardsSurvey < ApplicationForm
  attribute :person,        Person
  # TODO keep this consistent with other form objects and call the attribute
  # 'card_account_ids'
  attribute :card_accounts, Array

  def each_section
    Card.survey.group_by(&:bank).each do |bank, cards|
      yield bank, cards.group_by(&:bp)
    end
  end

  private

  def valid?
    card_accounts.each do |card_account|
      next unless card_account["closed"].present?
      opened_at_y = card_account["opened_at_(1i)"]
      opened_at_m = card_account["opened_at_(2i)"]
      closed_at_y = card_account["closed_at_(1i)"]
      closed_at_m = card_account["closed_at_(2i)"]
      if end_of_month(opened_at_y, opened_at_m) > end_of_month(closed_at_y, closed_at_m)
        errors.add("Open date", "cannot be greater than the close date")
        return false
      end
    end

    super
  end

  def persist!
    card_accounts.each do |card_account|
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
        opened_at: end_of_month(opened_at_y, opened_at_m),
      }

      if card_account["closed"].present?
        closed_at_y = card_account["closed_at_(1i)"]
        closed_at_m = card_account["closed_at_(2i)"]
        attributes["closed_at"] = end_of_month(closed_at_y, closed_at_m)
      end

      person.card_accounts.from_survey.create!(attributes)
    end

    onboarder = AccountOnboarder.new(person.account)
    if person.owner?
      onboarder.add_owner_cards!
    else
      onboarder.add_companion_cards!
    end
  end

  def end_of_month(year, month)
    Date.parse("#{year}-#{month}-01").end_of_month
  end
end
