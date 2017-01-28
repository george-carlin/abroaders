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
    end
  end
end
