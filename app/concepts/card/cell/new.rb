class Card < ApplicationRecord
  module Cell
    # model: the result of the Card::Operations::New operation
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

      def current_account
        result['account']
      end

      def ask_for_person_id?
        current_account.couples?
      end

      def form
        result['contract.default']
      end

      def _model
        result['model']
      end

      def product
        result['product']
      end

      # should only be called when the account has a companion
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
    end
  end
end
