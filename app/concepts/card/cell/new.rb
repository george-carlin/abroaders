class Card < ApplicationRecord
  module Cell
    # Shows a form to add a new card. The card *product* will already have been
    # selected on a previous page and is passed into this page by the params.
    #
    # if current account has a companion, has an extra input to select whether
    # the card is for the owner or for the companiothe companion
    #
    # model: the Result of the Card::Operations::New operation
    class New < Trailblazer::Cell
      include ActionView::Helpers::DateHelper
      include ActionView::Helpers::FormOptionsHelper
      include BootstrapOverrides
      # this include is necessary otherwise the specs fail; appears to be
      # a bug in Cells. See https://github.com/trailblazer/cells/issues/298 FIXME
      include ::Cell::Erb

      alias result model

      def initialize(result, opts = {}, *)
        raise 'card must have product initialized' if result['model'].product.nil?
        super
      end

      private

      def ask_for_person_id?
        current_account.couples?
      end

      def closed_at_select(f)
        f.date_select(
          :closed_at,
          class: 'cards_survey_select',
          disabled: disable_closed_at?,
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

      def disable_closed_at?
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
