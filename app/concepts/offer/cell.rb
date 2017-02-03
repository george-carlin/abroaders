class Offer::Cell < Trailblazer::Cell
  alias offer model

  def initialize(*args)
    warn "#{self.class} is deprecated"
    line = caller.select { |l| l.include?(Rails.root.to_s) }[1].split(':')[0..1].join(':')
    warn "Called from #{line}"
    super
  end

  property :cost
  property :days
  property :points_awarded
  property :spend

  include ::Cell::Builder
  include ::ActionView::Helpers::NumberHelper

  def cost
    warn "#{self.class}#cost is deprecated. Use Offer::Cell::Cost instead"
    line = caller.select { |l| l.include?(Rails.root.to_s) }[1].split(':')[0..1].join(':')
    warn "Called from #{line}"
    Offer::Cell::Cost.(model).()
  end

  def currency_name
    warn "#{self.class}#currency_name is deprecated."
    line = caller.select { |l| l.include?(Rails.root.to_s) }[1].split(':')[0..1].join(':')
    warn "Called from #{line}"
    offer.product.currency.name
  end

  def description
    warn "Offer::Cell#description is deprecated"
    line = caller.select { |l| l.include?(Rails.root.to_s) }[1].split(':')[0..1].join(':')
    warn "Called from #{line}"
    case model.condition
    when "on_minimum_spend"
      "Spend #{spend} within #{days} days to receive a bonus of "\
        "#{points_awarded} #{currency_name} points"
    when "on_approval"
      "#{points_awarded} #{currency_name} points awarded upon a successful application for this card."
    when "on_first_purchase"
      "#{points_awarded} #{currency_name} points awarded upon making your first purchase using this card."
    else raise "this should never happen"
    end
  end

  # A shorthand code that identifies the offer based on the points awarded,
  # minimum spend, and days. Note that this isn't necessarily unique per offer.
  def identifier(with_product: false)
    parts = [abbreviated_points]
    case offer.condition
    when "on_minimum_spend"
      parts.push(abbreviated_spend)
      parts.push(days)
    when "on_approval"
      parts.push("A")
    when "on_first_purchase"
      parts.push("P")
    else raise "this should never happen"
    end
    result = parts.join("/")
    # Note - we might eventually want to add a unique code per affiliate
    # to the end here
    if with_product
      "#{AdminArea::CardProduct::Cell::Identifier.(offer.product)}-#{result}"
    else
      result
    end
  end

  def points_awarded
    number_with_delimiter super
  end

  def spend
    number_to_currency super
  end

  private

  def abbreviated_points
    # Show points and spend as multiples of 1000, but don't print the decimal
    # point if it's an exact multiple:
    (offer.points_awarded / 1000.0).to_s.sub(/\.0+\z/, '')
  end

  def abbreviated_spend
    (offer.spend / 1000.0).to_s.sub(/\.0+\z/, '')
  end
end
