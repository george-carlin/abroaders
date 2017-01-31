class CardProduct < ApplicationRecord
  module Cell
    class Summary < Trailblazer::Cell
      private

      def bank_name
        model.bank.name
      end

      def image
        Image.(model, size: '130x81')
      end

      def name
        CardProduct::Cell::FullName.(model, network_in_brackets: true)
      end
    end
  end
end
