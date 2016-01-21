module CardsHelper

  def card_price_formatted(card)
    "$%.2f" % (card.annual_fee_cents / 100.0)
  end

  def options_for_card_brand_select
    options_for_enum_select(Card.brands)
  end

  def options_for_card_bp_select
    options_for_enum_select(Card.bps)
  end

  def options_for_card_type_select
    options_for_enum_select(Card.types)
  end

  private

  def options_for_enum_select(enum)
    options_for_select(enum.keys.each_with_object({}) do |key, hash|
      hash[key.capitalize] = key
    end)
  end

end
