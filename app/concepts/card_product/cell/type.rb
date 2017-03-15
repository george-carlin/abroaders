class CardProduct < CardProduct.superclass
  module Cell
    # Takes a CardProduct and returns its human-friendly type.
    #
    # p = CardProduct.new(type: :unknown_type)
    # CardProduct::Cell::Type.(p).() # => 'Unknown'
    class Type < Abroaders::Cell::Base
      property :type

      NAMES = {
        charge:       'Charge',
        credit:       'Credit',
        debit:        'Debit',
        unknown_type: 'Unknown',
      }.freeze

      def show
        NAMES.fetch(model.type.to_sym)
      end
    end
  end
end
