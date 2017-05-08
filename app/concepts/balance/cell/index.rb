class Balance < Balance.superclass
  module Cell
    # The top-level cell for the balances#index action.
    #
    # @!method self.call(account, opts = {})
    #   @param account [Account] the currently-logged in account. Make sure
    #     that the right associations are eager-loaded.
    class Index < Abroaders::Cell::Base
      property :people

      def show
        aw = cell(AwardWalletPanel, model)
        main = cell(PersonPanel, collection: people)
        "#{aw} #{main}"
      end

      private

      def people
        super.sort_by(&:type).reverse
      end
    end
  end
end
