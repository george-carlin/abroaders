module AdminArea
  module Cards
    module Cell
      # @!method self.call(card)
      #   @param card [Card]
      class TableRow < Abroaders::Cell::Base
        include Escaped

        property :id
        property :closed_on
        property :opened_on

        private

        def link_to_edit
          link_to 'Edit', edit_admin_card_path(model)
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
            # if model.recommended_at.nil? # if card is not a recommendation
            # super()&.strftime('%b %Y') || '-' # Dec 2015
            # else
            super()&.strftime('%D') || '-' # 12/01/2015
            # end
          end
        end

        def tr_tag(&block)
          content_tag(
            :tr,
            id: "card_#{id}",
            class: 'card',
            'data-bp':       product.bp,
            'data-bank':     product.bank_id,
            'data-currency': product.currency_id,
            &block
          )
        end

        def product
          model.product
        end

        def product_identifier
          cell(CardProducts::Cell::Identifier, product)
        end

        def product_name
          product.name
        end

        def status
          Inflecto.humanize(super)
        end
      end
    end
  end
end
