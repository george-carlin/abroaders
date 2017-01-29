class CardProduct < ApplicationRecord
  module Cell
    # Takes a card product and returns a pretty name for it
    #
    # option: 'with_bank'. default false. if true, include the bank's name in
    # the result.
    class FullName < Trailblazer::Cell
      property :bank
      property :bp
      property :name

      delegate :name, to: :bank, prefix: true

      def show
        parts = [name]
        parts.unshift(bank_name) if options[:with_bank]
        parts.push('business') if bp == 'business'
        # Amex will already be displayed as the bank name, so don't be redundant
        parts.push(network) unless bank_name == 'American Express'
        parts.join(" ")
      end

      private

      def network
        cell(Network, model)
      end
    end
  end
end
