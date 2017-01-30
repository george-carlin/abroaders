class Card < ApplicationRecord
  module Operations
    # Setup the form for a new card.
    #
    # required options:
    #   'person' => the Person who the card will belong to.
    class New < Trailblazer::Operation
      extend Contract::DSL
      contract ::Card::NewForm

      step :setup_model!
      step Contract::Build()

      private

      def setup_model!(opts, person:, **)
        opts['model'] = person.cards.new
      end

      class SelectProduct < Trailblazer::Operation
        step :load_products!
        step :load_banks!

        private

        def load_products!(opts)
          opts['collection'] = CardProduct.includes(:bank).order(name: :asc)
        end

        def load_banks!(opts)
          opts['banks'] = Bank.order(name: :asc)
        end
      end
    end
  end
end
