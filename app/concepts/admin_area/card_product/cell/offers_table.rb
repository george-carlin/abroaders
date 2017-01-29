module AdminArea
  module CardProduct
    module Cell
      class OffersTable < Trailblazer::Cell
        include ActionView::Helpers::RecordTagHelper

        alias product model

        private

        def offers
          product.offers.live
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

        # Wraps an Offer, needs a Person as an option
        class Row < Trailblazer::Cell
          property :link

          private

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
            @offer ||= cell(Offer::Cell, model)
          end
        end
      end
    end
  end
end
