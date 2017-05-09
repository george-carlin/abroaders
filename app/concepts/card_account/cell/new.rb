class CardAccount < CardAccount.superclass
  module Cell
    # Shows a form to add a new card. The card *product* will already have been
    # selected on a previous page and is passed into this page by the params.
    #
    # If current account has a companion, has an extra input to select whether
    # the card is for the owner or for the companiothe companion
    class New < Abroaders::Cell::Base
      # @param model [Card]
      # @option options [Reform::Form] form
      def initialize(model, options = {}, *)
        super
        raise 'card must have product initialized' if card_product.nil?
      end

      property :card_product
      property :account

      option :form

      private

      def ask_for_person_id?
        account.couples?
      end

      def closed_on_select(f)
        f.date_select(
          :closed_on,
          class: 'cards_survey_select',
          disabled: disable_closed_on?,
          discard_day: true,
          end_year:   Date.today.year,
          order:      [:month, :year],
          start_year: Date.today.year - 10,
          use_short_month: true,
        )
      end

      def disable_closed_on?
        !form.closed
      end

      def link_to_select_different_product
        link_to 'Cancel', cards_path
      end

      # don't call this 'options' as that conflicts with the Cells method!
      def options_for_person_id_select
        owner     = account.owner
        companion = account.companion
        options_for_select(
          [
            [owner.first_name, owner.id],
            [companion.first_name, companion.id],
          ],
        )
      end

      # two divs with cols XS 12/12, SM 6/6, MD 2/4:
      def product_summary
        cell(CardProduct::Cell::Summary, card_product)
      end
    end
  end
end
