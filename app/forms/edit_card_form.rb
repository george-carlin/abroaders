class EditCardForm < ApplicationForm
  attribute :id,           Integer
  attribute :opened_year,  String
  attribute :opened_month, String
  attribute :closed_year,  String
  attribute :closed_month, String
  attribute :closed,       Boolean

  def self.model_name
    Card.model_name
  end

  def self.find(account, id)
    card = account.cards.find(id)
    new_attributes = {
      opened_year:  card.opened_at.year,
      opened_month: card.opened_at.month,
    }

    if card.closed?
      new_attributes[:closed] = true
      new_attributes[:closed_year]  = card.closed_at.year
      new_attributes[:closed_month] = card.closed_at.month
    else
      new_attributes[:closed] = false
    end

    new(card.attributes.merge(new_attributes))
  end

  def card
    @card ||= Card.find(id)
  end

  def persisted?
    true
  end

  private

  def persist!
    card.update!(
      opened_at: Date.new(opened_year, opened_month),
      closed_at: closed ? Date.new(closed_year, closed_month) : nil,
    )
  end
end
