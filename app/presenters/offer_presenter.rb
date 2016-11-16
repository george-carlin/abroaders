class OfferPresenter < ApplicationPresenter
  delegate :name, :identifier, to: :product, prefix: true
  delegate :bank_name, to: :product

  # A shorthand code that identifies the offer based on the points awarded,
  # minimum spend, and days. Note that this isn't necessarily unique per offer.
  def identifier(with_product: false)
    parts = [abbreviated_points]
    case model.condition
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
      "#{product_identifier}-#{result}"
    else
      result
    end
  end

  def condition
    super().humanize
  end

  # Note that any links to the offer MUST be nofollowed, for compliance reasons
  def link_to_link(text: "Link")
    h.link_to text, link, rel: "nofollow", target: "_blank"
  end

  def spend
    h.number_to_currency super()
  end

  def cost
    h.number_to_currency super()
  end

  def points_awarded
    h.number_with_delimiter super()
  end

  def currency_name
    product.currency_name
  end

  def partner_full_name
    case partner
    when "card_ratings" then "CardRatings.com"
    when "credit_cards" then "CreditCards.com"
    when "award_wallet" then "AwardWallet"
    when "card_benefit" then "CardBenefit"
    else "-"
    end
  end

  def partner_short_name
    case partner
    when "card_ratings" then "CR"
    when "credit_cards" then "CC"
    when "award_wallet" then "AW"
    when "card_benefit" then "CB"
    else "-"
    end
  end

  def description
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

  private

  def product
    @product ||= Card::Product::Presenter.new(super(), view)
  end

  def abbreviated_points
    # Show points and spend as multiples of 1000, but don't print the decimal
    # point if it's an exact multiple:
    (model.points_awarded / 1000.0).to_s.sub(/\.0+\z/, '')
  end

  def abbreviated_spend
    (model.spend / 1000.0).to_s.sub(/\.0+\z/, '')
  end
end
