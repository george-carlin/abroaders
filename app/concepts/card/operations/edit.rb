class Card < ApplicationRecord
  module Operations
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

      # Where to search for the card. Must returns an object which must respond
      # to `find`. By default, returns the current account's cards, but you can
      # override this with the 'card_scope' skill (e.g. you could set it to
      # `Card` if you want to search *all* cards for an admin action.)
      def card_scope(*)
        self['card_scope'] || self['current_account'].cards
      end
    end
  end
end
