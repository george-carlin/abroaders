class NewCardAccountForm < CardAccountForm
  attribute :card, ::Card

  def self.name
    "CardCardAccount"
  end

  private

  def persist!
    attributes = {
      card: card,
      person: person,
      opened_at: end_of_month(opened_year, opened_month)
    }

    if closed
      attributes[:closed_at] = end_of_month(closed_year, closed_month)
    else
      attributes[:closed_at] = nil
    end

    ::CardAccount.create!(attributes)
  end
end
