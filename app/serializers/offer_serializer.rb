class OfferSerializer < ApplicationSerializer
  include ActionView::Helpers

  attributes :id, :points_awarded, :spend, :cost, :days, :link,
             :notes, :condition, :last_reviewed_at, :partner, :identifier
  belongs_to :card

  always_include :card

  def spend
    number_to_currency(object.spend)
  end

  def cost
    number_to_currency(object.cost)
  end

  def points_awarded
    number_with_delimiter(object.points_awarded)
  end

  def identifier(with_card: false)
    parts = [abbreviated_points]
    case object.condition
    when "on_minimum_spend"
      parts.push(abbreviated_spend)
      parts.push(object.days)
    when "on_approval"
      parts.push("A")
    when "on_first_purchase"
      parts.push("P")
    else raise "this should never happen"
    end
    result = parts.join("/")
    # Note - we might eventually want to add a unique code per affiliate
    # to the end here
    if with_card
      "#{card.identifier}-#{result}"
    else
      result
    end
  end

  private

  def abbreviated_points
    # Show points and spend as multiples of 1000, but don't print the decimal
    # point if it's an exact multiple:
    (object.points_awarded / 1000.0).to_s.sub(/\.0+\z/, '')
  end

  def abbreviated_spend
    (object.spend / 1000.0).to_s.sub(/\.0+\z/, '')
  end
end
