module CardsHelper

  def card_price_formatted(card)
    "$%.2f" % (card.annual_fee_cents / 100.0)
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

  def card_currency_filter_check_box_tag(currency_id)
    klass =  :card_currency_filter
    id    =  :"#{klass}_#{currency_id}"
    label_tag id do
      check_box_tag(
        id,
        nil,
        true,
        class: klass,
        data: { key: :currency, value: currency_id }
      ) << raw("&nbsp;&nbsp#{Currency.new(currency_id).short_name}")
    end
  end

end
