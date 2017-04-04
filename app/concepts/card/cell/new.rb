class Card < Card.superclass
  module Cell
    # Shows a form to add a new card. The card *product* will already have been
    # selected on a previous page and is passed into this page by the params.
    #
    # if current account has a companion, has an extra input to select whether
    # the card is for the owner or for the companiothe companion
    #
    # model: the Result of the Card::Operation::New operation
    class New < Abroaders::Cell::Base
      alias result model

      def initialize(result, opts = {}, *)
        raise 'card must have product initialized' if result['model'].product.nil?
        super
      end

      private

      def ask_for_person_id?
        current_account.couples?
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

      def current_account
        result['account']
      end

      def disable_closed_on?
        !form.closed
      end

      def form
        result['contract.default']
      end

      def link_to_select_different_product
        link_to 'Cancel', cards_path
      end

      # don't call this 'options' as that conflicts with the Cells method!
      def options_for_person_id_select
        owner     = current_account.owner
        companion = current_account.companion
        options_for_select(
          [
            [owner.first_name, owner.id],
            [companion.first_name, companion.id],
          ],
        )
      end

      def product
        result['product']
      end
    end
  end
end
