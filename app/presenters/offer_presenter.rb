class OfferPresenter < ApplicationPresenter

  # A shorthand code that identifies the offer based on the points awarded,
  # minimum spend, and days. Note that this isn't necessarily unique per offer.
  def identifier(with_card: false)
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
    if with_card
      "#{card_identifier}-#{result}"
    else
      result
    end
  end

  def condition
    super().humanize
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
    card.currency_name
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

  def recommend_btn
    btn_classes = "btn btn-xs btn-primary"
    prefix = :recommend
    h.button_tag(
      "Recommend",
      class: "#{h.dom_class(self, prefix)}_btn #{btn_classes} pull-right",
      id:    "#{h.dom_id(self, prefix)}_btn"
    )
  end

  def confirm_recommend_btn(person)
    btn_classes = "btn btn-xs btn-primary"
    prefix = :confirm_recommend
    h.button_to(
      "Confirm",
      h.admin_person_card_recommendations_path(person),
      class:  "#{h.dom_class(self, prefix)}_btn #{btn_classes} pull-right",
      id:     "#{h.dom_id(self, prefix)}_btn",
      params: { offer_id: id }
    )
  end

  def cancel_recommend_btn
    btn_classes = "btn btn-xs btn-default"
    prefix = :cancel_recommend
    h.button_tag(
      "Cancel",
      class: "#{h.dom_class(self, prefix)}_btn #{btn_classes} pull-right",
      id:    "#{h.dom_id(self, prefix)}_btn"
    )
  end

  private

  def card
    @card ||= CardPresenter.new(super(), view)
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
