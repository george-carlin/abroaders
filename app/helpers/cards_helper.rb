module CardsHelper

  def card_price_formatted(card)
    "$%.2f" % (card.annual_fee_cents / 100.0)
  end

  def card_image_tag(card, size="180x114")
    image_tag card.image.url, size: size
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

  def card_bank_filter_check_box_tag(bank)
    klass =  :card_bank_filter
    id    =  :"#{klass}_#{bank.id}"
    label_tag id do
      check_box_tag(
        id,
        nil,
        true,
        class: klass,
        data: { key: :bank, value: bank.id }
      ) << raw("&nbsp;&nbsp#{bank.name}")
    end
  end

  def card_currency_filter_check_box_tag(currency)
    klass =  :card_currency_filter
    id    =  :"#{klass}_#{currency.id}"
    label_tag id do
      check_box_tag(
        id,
        nil,
        true,
        class: klass,
        data: { key: :currency, value: currency.id }
      ) << raw("&nbsp;&nbsp#{currency.name}")
    end
  end

end
