class Card < ApplicationRecord
  module Operations
    # Setup the form for a new card.
    #
    # This op is also nested within from Card::Operations::Create
    #
    # options:
    #   'account': the currently logged-in account
    #
    # params:
    #   'product_id': the id of CardProduct that the Card will belong_to.
    #       The user will select the product on /cards/new (which
    #       uses the SelectProduct op, not the New op), then they'll see the
    #       'real' form on /products/:product_id/cards/new. The form
    #       will then post to /products/:product_id/cards, meaning that
    #       :product_id should *always* be present in the params for New
    #   'card': the attributes of the new card. optional (only used by Create).
    #       params[:card][:person_id] will only be present if the current
    #       user is a couples account. If it's not present, the person will
    #       default to the account's owner. Note that a 'person' option WON'T
    #       be passed in from the controller in either case, since we're
    #       talking about params[:card][:person_id], not params[:person_id]
    #
    class New < Trailblazer::Operation
      extend Contract::DSL
      contract ::Card::NewForm

      step :setup_person!
      step :setup_model!
      success :find_product!
      step Contract::Build()

      private

      def setup_person!(opts, params:, account:, **)
        if params[:card] && params[:card][:person_id]
          opts['person'] = account.people.find(params[:card][:person_id])
        else
          opts['person'] = account.owner
        end
      end

      def setup_model!(opts, person:, **)
        opts['model'] = person.cards.new
      end

      # if params contain product_id (will come from a GET param), find the
      # CardProduct and set card.product. (This will be used to fill the value
      # of a hidden field in the <form>). Also set opts['product']
      def find_product!(opts, params:, **)
        opts['model'].product = opts['product'] = CardProduct.find(params[:product_id])
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
