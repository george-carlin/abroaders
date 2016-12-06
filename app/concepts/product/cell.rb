class Product::Cell < Trailblazer::Cell
  property :annual_fee_cents
  property :bank
  property :bp
  property :code
  property :created_at
  property :currency
  property :image
  property :id
  property :name
  property :network
  property :type
  property :updated_at
  property :wallaby_id

  delegate :name, to: :bank, prefix: true

  include ActionView::Helpers::NumberHelper

  def annual_fee
    number_to_currency(annual_fee_cents / 100)
  end

  def bp
    Inflecto.humanize(super)
  end

  def currency_name
    currency.nil? ? 'None' : currency.name
  end

  def full_name(with_bank: false)
    @full_name ||= begin
      parts = [name]
      parts.unshift(bank_name) if with_bank
      parts.push("business") if model.bp == 'business'
      # Amex will already be displayed as the bank name, so don't be redundant
      parts.push(network) unless bank_name == "American Express"
      parts.join(" ")
    end
  end

  def identifier
    Card::Product::Identifier.new(model)
  end

  def image(size = "180x114")
    image_tag super().url, size: size
  end

  def network
    I18n.t("activerecord.attributes.card_product.networks.#{super}")
  end

  def type
    I18n.t("activerecord.attributes.card_product.types.#{super}")
  end

  # Hack to prevent annoying autoload error. See Rails issue #14844
  autoload :Admin, 'product/cell/admin'
end
