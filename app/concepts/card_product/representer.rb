class CardProduct < CardProduct.superclass
  class Representer < Representable::Decorator
    include Representable::JSON

    defaults render_nil: true

    property :name
    property :network
    property :bp
    property :type

    property :bank, decorator: Bank::Representer
  end
end
