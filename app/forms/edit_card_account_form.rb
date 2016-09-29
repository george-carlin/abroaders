class EditCardAccountForm < ApplicationForm
  attribute :id, Integer
  attribute :opened_year, String
  attribute :opened_month, String
  attribute :closed_year, String
  attribute :closed_month, String
  attribute :closed, Boolean

  def self.name
    "CardAccount"
  end

  def self.find(id)
    card_account = ::CardAccount.find(id)
    new_attributes = {
        opened_year:  card_account.opened_at.year,
        opened_month: card_account.opened_at.month
    }

    if card_account.closed?
      new_attributes[:closed] = true
      new_attributes[:closed_year] = card_account.closed_at.year,
      new_attributes[:closed_month] = card_account.closed_at.month
    else
      new_attributes[:closed] = false
    end

    new(card_account.attributes.merge(new_attributes))
  end

  def card_account
    @card_account ||= CardAccount.find(id)
  end

  def persisted?
    true
  end

  private

  def persist!
    attributes = {
        opened_at: end_of_month(opened_year, opened_month)
    }

    if closed
      attributes[:closed_at] = end_of_month(closed_year, closed_month)
    else
      attributes[:closed_at] = nil
    end

    card_account.update!(attributes)
  end

  def end_of_month(year, month)
    Date.parse("#{year}-#{month}-01").end_of_month
  end
end
