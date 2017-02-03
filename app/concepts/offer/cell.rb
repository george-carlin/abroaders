class Offer::Cell < Trailblazer::Cell
  alias offer model

  def initialize(*args)
    warn "#{self.class} is deprecated"
    line = caller.select { |l| l.include?(Rails.root.to_s) }[1].split(':')[0..1].join(':')
    warn "Called from #{line}"
    super
  end

  property :days

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
    Offer::Cell::Description.(model).()
  end

  def points_awarded
    Offer::Cell::PointsAwarded.(model).()
  end

  def spend
    Offer::Cell::Spend.(model).()
  end
end
