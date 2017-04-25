class Bank < Bank.superclass
  class Representer < Representable::Decorator
    include Representable::JSON

    defaults render_nil: true

    property :id
    property :name
    property :personal_phone
    property :business_phone
  end
end
