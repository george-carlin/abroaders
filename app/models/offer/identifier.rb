# Note - we might eventually want to add a unique code per affiliate
# to the end of this identifier.
class Offer::Identifier
  def initialize(offer)
    @offer = offer
  end

  def full
    "#{@offer.card_identifier}-#{self}"
  end

  def to_s
    parts = [points]
    case @offer.condition
    when "on_minimum_spend"
      parts.push(spend)
      parts.push(@offer.days)
    when "on_approval"
      parts.push("A")
    when "on_first_purchase"
      parts.push("P")
    else raise "this should never happen"
    end
    parts.join("/")
    # Note - we might eventually want to add a unique code per affiliate
    # to the end here
  end

  def ==(other_identifier)
    to_s == other_identifier.to_s
  end

  def <=>(other_identifier)
    to_s <=> other_identifier.to_s
  end

  def inspect
    "\"#{self}\""
  end

  private

  def points
    # Show points and spend as multiples of 1000, but don't print the decimal
    # point if it's an exact multiple:
    (@offer.points_awarded / 1000.0).to_s.sub(/\.0+\z/, '')
  end

  def spend
    (@offer.spend / 1000.0).to_s.sub(/\.0+\z/, '')
  end

end
