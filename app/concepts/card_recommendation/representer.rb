class CardRecommendation < CardRecommendation.superclass
  class Representer < Representable::Decorator
    include Representable::JSON

    defaults render_nil: true

    property :id
    property :recommended_at
    property :applied_on
    property :opened_on
    property :closed_on
    property :decline_reason
    property :clicked_at
    property :declined_at
    property :denied_at
    property :nudged_at
    property :called_at
    property :redenied_at

    property :card_product, decorator: CardProduct::Representer
  end
end
