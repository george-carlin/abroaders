module AdminArea::People::Cell
  class Show < Show.superclass
    # Takes the person, shows their card accounts. Has a header that says
    # 'Accounts' and a link to add a new CA for the person. If there aren't any
    # CAs, there'll be a <p> that tells you so. If there are CAs, they'll be
    # listed in a <table>.
    #
    # @!method self.call(person, options = {})
    #   @param person [Person] make sure that card_accounts => product => bank
    #     is eager-loaded.
    class CardAccounts < Abroaders::Cell::Base
      property :card_accounts

      private

      def link_to_add_new
        link_to raw('&plus; Add'), new_admin_person_card_account_path(model)
      end

      def table_rows
        cell(Row, collection: card_accounts)
      end

      def table_tag(&block)
        content_tag(
          :table,
          class: 'table table-striped tablesorter',
          id: 'admin_person_card_accounts_table',
          &block
        )
      end

      # @!method self.call(card_account)
      #   @param card [CardAccount]
      class Row < Abroaders::Cell::Base
        include Escaped

        property :id
        property :card_product
        property :closed_on
        property :offer
        property :opened_on
        property :recommended?

        private

        delegate :bp, to: :card_product, prefix: true

        def card_product_name
          cell(CardProduct::Cell::FullName, card_product, with_bank: true)
        end

        def link_to_edit
          link_to 'Edit', edit_admin_card_account_path(model)
        end

        def link_to_offer
          if offer.nil?
            '-'
          else
            link_to offer_identifier, admin_offer_path(offer)
          end
        end

        # If the card was opened/closed after being recommended by an admin,
        # we know the exact date it was opened closed. If they added the card
        # themselves (e.g. when onboarding), they only provide the month
        # and year, and we save the date as the 1st of thet month.  So if the
        # card was added as a recommendation, show the the full date, otherwise
        # show e.g.  "Jan 2016". If the date is blank, show '-'
        #
        # TODO rethink how we know whether a card was added in the survey
        %i[closed_on opened_on].each do |date_attr|
          define_method date_attr do
            if model.recommended?
              super()&.strftime('%D') || '-' # 12/01/2015
            else
              super()&.strftime('%b %Y') || '-' # Dec 2015
            end
          end
        end

        def tr_tag(&block)
          content_tag(
            :tr,
            id: "card_account_#{id}",
            class: 'card_account',
            'data-bp':       card_product.bp,
            'data-bank':     card_product.bank_id,
            &block
          )
        end

        def offer_identifier
          cell(AdminArea::Offers::Cell::Identifier, offer, with_partner: true)
        end
      end
    end
  end
end
