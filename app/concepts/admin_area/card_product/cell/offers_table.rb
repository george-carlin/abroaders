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
          property :link

          private

          def cost
            cell(::Offer::Cell::Cost, model)
          end

          def person
            options.fetch(:person)
          end

          def buttons_to_recommend
            cell(AdminArea::Recommendation::Cell::New, nil, offer: model, person: person)
          end

          def html_id
            dom_id(model, :admin_recommend)
          end

          def html_classes
            dom_class(model, :admin_recommend)
          end

          # Note that any links to the offer MUST be nofollowed, for compliance reasons
          def link_to_link
            link_to 'Link', link, rel: 'nofollow', target: '_blank'
          end

          def offer
            @offer ||= cell(AdminArea::Offer::Cell, model)
          end
        end
      end
    end
  end
end
