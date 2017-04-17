module AdminArea
  module CardProducts
    module Cell
      # The table of offers for a particular product. Each offer has a
      # 'recommend' button for the admin to recommend the offer to a person.
      #
      # There'll be one of these tables for each product that has at least one
      # recommendable offer. Each OffersTable <table> is nested within a <tr>
      # in the parent table. Between each of those <tr>s (i.e.  outside the
      # scope of the OffersTable cell) is *another* <tr> that contains the
      # information about the CardProduct itself.
      class OffersTable < Abroaders::Cell::Base
        property :id
        property :recommendable_offers

        option :person

        # @param model [CardProduct] a card product.  Must have at least one
        #   live offer; cell will raise an error if it doesn't. TODO N+1
        # @option options [Person] person the person whom the offers will be
        #   recommended to
        def initialize(product, options = {})
          raise 'no offers' if product.recommendable_offers.empty?
          super
        end

        private

        def rows
          cell(Row, collection: recommendable_offers, person: person)
        end

        def html_id
          "admin_recommend_card_product_#{id}_offers_table"
        end

        def html_classes
          'admin_recommend_card_product_offers_table table'
        end

        # a single `<tr>` containing an signup offer that can be recommended
        #   for the product
        #
        # @!method self.call(model, opts = {})
        #   @param model [Offer]
        #   @option opts [Person] the Person whom the offer will be recommended
        #     to
        class Row < Abroaders::Cell::Base
          property :id
          property :days
          property :link

          option :person

          private

          def buttons_to_recommend
            cell(CardRecommendations::Cell::New, nil, offer: model, person: person)
          end

          def cost
            cell(Offer::Cell::Cost, model)
          end

          def html_classes
            'admin_recommend_offer'
          end

          def html_id
            "admin_recommend_offer_#{id}"
          end

          # Note that any links to the offer MUST be nofollowed for compliance reasons
          def link_to_link
            link_to 'Link', link, rel: 'nofollow', target: '_blank'
          end

          def identifier
            cell(Offers::Cell::Identifier, model)
          end

          def points_awarded
            cell(Offer::Cell::PointsAwarded, model)
          end

          def spend
            cell(Offer::Cell::Spend, model)
          end
        end
      end
    end
  end
end
