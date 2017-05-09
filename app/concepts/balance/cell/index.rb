class Balance < Balance.superclass
  module Cell
    # The top-level cell for the balances#index action.
    #
    # @!method self.call(account, opts = {})
    #   @param account [Account] the currently-logged in account. Make sure
    #     that the right associations are eager-loaded.
    class Index < Abroaders::Cell::Base
      property :people
      property :connected_to_award_wallet?

      def show
        award_wallet.to_s << main.to_s
      end

      private

      def award_wallet
        cell(AwardWalletPanel, model)
      end

      def main
        cell(PersonPanel, collection: people, simple: !connected_to_award_wallet?)
      end

      def people
        super.sort_by(&:type).reverse
      end
    end
  end
end
