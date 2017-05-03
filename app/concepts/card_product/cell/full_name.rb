class CardProduct < CardProduct.superclass
  module Cell
    # Takes a card product and returns a pretty name for it
    #
    # @!method self.call(card_product, options = {})
    #   @param card_product [CardProduct]
    #   @option options [Boolean] with_bank (false) if true, result includes
    #     bank's name. If bank name is American Express, don't include it
    #     (because the network will also be AmEx, so the words 'American
    #     Express' will already be included in the name.
    #   @option options [Boolean] network_in_brackets (false) Wrap the name of
    #     the network in brackets, e.g. 'Chase Sapphire (Visa)'. When this
    #     option is false it'll be 'Chase Sapphire Visa'
    class FullName < Abroaders::Cell::Base
      property :bank
      property :business?
      property :name

      option :with_bank, default: false
      option :network_in_brackets, default: false

      delegate :name, to: :bank, prefix: true

      def show
        parts = [name]
        parts.unshift(bank_name) if with_bank
        parts.push('business') if business?
        # Amex will already be displayed as the bank name, so don't be redundant
        parts.push(network) unless exclude_network?
        parts.join(' ')
      end

      private

      def network
        name = cell(Network, model)
        if network_in_brackets
          "(#{name})"
        else
          name
        end
      end

      def exclude_network?
        model.network == 'unknown_network' || (bank_name == 'American Express' && with_bank)
      end
    end
  end
end
