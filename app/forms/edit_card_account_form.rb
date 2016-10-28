class EditCardAccountForm < ApplicationForm
  attribute :id,           Integer
  attribute :opened_year,  String
  attribute :opened_month, String, default: Date.today.month
  attribute :closed_year,  String, default: Date.today.year
  attribute :closed_month, String
  attribute :closed,       Boolean

  validate :closed_date, if: proc { |card| card.closed? }

  def self.name
    "CardAccount"
  end

  def self.find(account, id)
    card_account = account.card_accounts.find(id)
    new_attributes = {
      opened_year:  card_account.opened_at.year,
      opened_month: card_account.opened_at.month,
    }

    if card_account.closed?
      new_attributes[:closed] = true
      new_attributes[:closed_year]  = card_account.closed_at.year
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
    card_account.update!(
      opened_at: end_of_month(opened_year, opened_month),
      closed_at: closed? ? end_of_month(closed_year, closed_month) : nil,
    )
  end

  def closed_date
    if end_of_month(opened_year, opened_month) > end_of_month(closed_year, closed_month)
      errors.add("Open date", "cannot be greater than the close date")
    end
  end

  def end_of_month(year, month)
    Date.parse("#{year}-#{month}-01").end_of_month
  end
end
