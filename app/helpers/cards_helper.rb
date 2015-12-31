module CardsHelper

  def card_price_formatted(card)
    "$%.2f" % (card.annual_fee_cents / 100.0)
  end

end
