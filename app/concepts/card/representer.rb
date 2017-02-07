class Card < Card.superclass
  class Representer < Representable::Decorator
    include Representable::JSON

    defaults render_nil: true

    property :id

    property :closed_on
    property :offer_id
    property :opened_on
    property :person_id
    property :product_id

    property :created_at
    property :updated_at
  end
end
