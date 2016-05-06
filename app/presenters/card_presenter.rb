class CardPresenter < ApplicationPresenter

  delegate :name, to: :currency, prefix: true

  def image(size="180x114")
    h.image_tag super().url, size: size
  end

  def network
    t("activerecord.attributes.card.networks.#{super()}")
  end

  def full_name(with_bank: false)
    @full_name ||= begin
      parts = [name]
      parts.unshift(bank_name) if with_bank
      parts.push("business") if business?
      # Amex will already be displayed as the bank name, so don't be redundant
      parts.push(network) unless bank_name == "American Express"
      parts.join(" ")
    end
  end

  def annual_fee
    h.number_to_currency(annual_fee_cents / 100)
  end

  def bp
    super().humanize
  end

  def type
    t("activerecord.attributes.card.types.#{super()}")
  end


end
