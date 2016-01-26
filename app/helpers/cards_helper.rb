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

  def card_image_tag(card, size="180x114")
    id  = card.identifier
    dir = Rails.root.join("app", "assets", "images", "cards")
    if File.exists?(dir.join("#{id}.png"))
      image_tag "cards/#{id}.png", size: size
    elsif File.exists?(dir.join("#{id}.jpg"))
      image_tag "cards/#{id}.jpg", size: size
    else
      "Not found - #{id}"
    end
  end

  def card_bp_filter_check_box_tag(bp)
    klass =  :card_bp_filter
    id    =  :"#{klass}_#{bp}"
    label_tag id do
      check_box_tag(
        id,
        nil,
        true,
        class: klass,
        data: { key: :bp, value: bp }
      ) << raw("&nbsp;&nbsp#{bp.capitalize}")
    end
  end

  def card_bank_filter_check_box_tag(bank_id)
    klass =  :card_bank_filter
    id    =  :"#{klass}_#{bank_id}"
    label_tag id do
      check_box_tag(
        id,
        nil,
        true,
        class: klass,
        data: { key: :bank, value: bank_id }
      ) << raw("&nbsp;&nbsp#{BankName.new(bank_id).name}")
    end
  end

  private

  def options_for_enum_select(enum)
    options_for_select(enum.keys.each_with_object({}) do |key, hash|
      hash[key.capitalize] = key
    end)
  end

end
