class CardProduct < CardProduct.superclass
  module Cell
    # Takes a CardProduct and returns its human-friendly type.
    #
    # p = CardProduct.new(type: 'unknown')
    # CardProduct::Cell::Type.(p).() # => 'Unknown'
    class Type < Abroaders::Cell::Base
      property :type

      NAMES = {
        charge: 'Charge',
        credit: 'Credit',
        debit: 'Debit',
        unknown: 'Unknown',
      }.freeze

      def show
        NAMES.fetch(model.type.to_sym)
      end
    end
  end
end
