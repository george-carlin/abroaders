module AdminArea
  module CardProduct
    module Cell
      # The table of offers for a particular product. Each offer has a
      # 'recommend' button for the admin to recommend the offer to a person.
      #
      # @!method self.call(model, opts = {})
      #   @param model [Collection<Offer>] a collection of offers that
      #     can be recommended
      #   @option opts [CardProduct] product the product being offered
      #   @option opts [Person] person the person whom the offers will be
      #     recommended to
      class OffersTable < Trailblazer::Cell
        include ActionView::Helpers::RecordTagHelper
        extend Abroaders::Cell::Options

        alias offers model

        option :person
        option :product

        private

        def rows
          cell(Row, collection: offers, person: person)
        end

        def html_id
          "admin_recommend_card_product_#{product.id}_offers_table"
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
        class Row < Trailblazer::Cell
          extend Abroaders::Cell::Options

          property :id
          property :days
          property :link

          option :person

          private

          def buttons_to_recommend
            cell(AdminArea::CardRecommendation::Cell::New, nil, offer: model, person: person)
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
