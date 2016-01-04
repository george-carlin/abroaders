module CardsHelper

  def card_price_formatted(card)
    "$%.2f" % (card.annual_fee_cents / 100.0)
  end

  def options_for_card_brand_select
    options_for_select(Card.brands.keys.each_with_object({}) do |brand, hash|
      hash[brand.capitalize] = brand
    end)
  end

  def options_for_card_bp_select
    options_for_select(Card.bps.keys.each_with_object({}) do |bp, hash|
      hash[bp.capitalize] = bp
    end)
  end

  def options_for_card_type_select
    options_for_select(Card.types.keys.each_with_object({}) do |type, hash|
      hash[type.capitalize] = type
    end)
  end

end
