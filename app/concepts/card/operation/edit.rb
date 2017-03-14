class Card < Card.superclass
  module Operation
    # Find a Card by its ID, and prepare to edit it
    class Edit < Trailblazer::Operation
      extend Contract::DSL
      contract Card::Form

      step :setup_model!
      step Contract::Build()

      private

      def setup_model!(options, params:, **)
        options['model'] = card_scope.find(params[:id])
      end

      # Where to search for the card. Must return an object which responds to
      # `find`. By default, returns the account's cards, but you can override
      # this with the 'card_scope' skill (e.g. you could set it to `Card` if
      # you want to search *all* cards for an admin action.)
      def card_scope(*)
        self['card_scope'] || self['account'].cards
      end
    end
  end
end
