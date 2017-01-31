class Card < ApplicationRecord
  module Cell
    # model: the result of the Card::Operations::New operation
    #
    # options:
    #   - current_account: the current Account (duh)
    class New < Trailblazer::Cell
      include ActionView::Helpers::DateHelper
      include BootstrapOverrides::Overrides
      include Partial # for the validation errors. TODO extract partial to cell

      alias result model

      def initialize(result, opts = {}, *)
        raise 'card must have product initialized' if result['model'].product.nil?
        super
      end

      private

      def form
        result['contract.default']
      end

      def _model
        result['model']
      end

      def product
        result['product']
      end

      def validation_errors
        render partial: 'shared/reform_validation_errors', model: form
      end
    end
  end
end
