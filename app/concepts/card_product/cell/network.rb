class CardProduct < CardProduct.superclass
  module Cell
    # Takes a CardProduct and returns its network as a human-friendly string.
    #
    # p = CardProduct.new(network: 'amex')
    # CardProduct::Cell::Network.(p).() # => 'American Express'
    class Network < Abroaders::Cell::Base
      property :network

      NAMES = {
        amex: 'American Express',
        mastercard: 'MasterCard',
        unknown: 'Unknown',
        visa: 'Visa',
      }.freeze

      def show
        NAMES.fetch(network.to_sym)
      end
    end
  end
end
