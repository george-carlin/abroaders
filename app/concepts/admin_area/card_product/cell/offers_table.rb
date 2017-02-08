module AdminArea
  module CardProduct
    module Cell
      # The table of offers for a particular product. Each offer has a
      # 'recommend' button for the admin to recommend the offer to a person.
      #
      # model: a collection of offers
      # options:
      #   product: the product which the offers belong to
      #   person: the person who the offers will be recommended to
      class OffersTable < Trailblazer::Cell
        include ActionView::Helpers::RecordTagHelper

        alias offers model

        private

        def person
          options.fetch(:person)
        end

        def product
          options.fetch(:product)
        end

        def rows
          cell(Row, collection: offers, person: options[:person])
        end

        def html_id
          "#{dom_id(product, :admin_recommend)}_offers_table"
        end

        def html_classes
          "#{dom_class(product, :admin_recommend)}_offers_table table"
        end

        # model: an Offer
        # options:
        #   person: the Person who the offer will be recommended to.
        class Row < Trailblazer::Cell
          property :id
          property :link

          private

          def buttons_to_recommend
            person = options.fetch(:person)
            cell(AdminArea::CardRecommendation::Cell::New, nil, offer: model, person: person)
          end

          def cost
            cell(::Offer::Cell::Cost, model)
          end

          def days
            model.days
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
            cell(AdminArea::Offer::Cell::Identifier, model)
          end

          def points_awarded
            cell(::Offer::Cell::PointsAwarded, model)
          end

          def spend
            cell(::Offer::Cell::Spend, model)
          end
        end
      end
    end
  end
end
