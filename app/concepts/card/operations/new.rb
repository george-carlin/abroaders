class Card < ApplicationRecord
  module Operations
    # Setup the form for a new card. If
    #
    # This op is also nested within from Card::Operations::Create
    #
    # options:
    #   'account': the currently logged-in account
    #   'person' (optional) the Person who the card will belong to. Defaults
    #       to the account owner.
    #
    # params:
    #   'product_id': the pre-selected CardProduct that the card will belong_to.
    #       optional, because it's only used by the 'new' action, not 'create'.
    #
    class New < Trailblazer::Operation
      extend Contract::DSL
      contract ::Card::NewForm

      step :set_default_person!
      step :setup_model!
      success :find_product!
      step Contract::Build()

      private

      def set_default_person!(opts, account:, **)
        opts['person'] ||= account.owner
      end

      def setup_model!(opts, person:, **)
        opts['model'] = person.cards.new
      end

      # if params contain product_id (will come from a GET param), find the
      # CardProduct and set card.product. (This will be used to fill the value
      # of a hidden field in the <form>). Also set opts['product']
      def find_product!(opts, params:, **)
        if (id = product_id(params))
          opts['model'].product ||= opts['product'] = CardProduct.find(id)
        end
      end

      def product_id(params)
        params[:product_id] || (params[:card] && params[:card][:product_id])
      end

      # when no product ID is provided in the params, show this page instead so
      # they can choose a product.
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
