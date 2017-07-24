module AdminArea::Currencies
  # @!method self.call(params, options = {})
  class Form < Reform::Form
    feature Coercion

    property :name, type: Types::StrippedString
    property :type, type: Currency::Type.default('airline')
    property :alliance_name, type: Alliance::Name.default('Independent')

    validates :name, presence: true
  end
end
