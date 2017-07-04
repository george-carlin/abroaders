module AdminArea::CardAccounts
  module Cell
    # @!method self.call(model, options = {})
    #   @option options [Reform::Form] form
    class New < Edit
      def title
        'New Card Account '
      end

      private

      def form_url
        admin_person_card_accounts_path(person)
      end
    end
  end
end
