module AdminArea
  module CardRecommendation
    module Cell
      # main cell for /admin/people/:person_id/recommendations/pulled
      #
      # Lists the recommendations that were made to the given person, but
      # were then pulled by an admin.
      #
      # model: a TRB operation result. must have keys:
      #   collection: a collection of CardRecommendations
      #   person: the person
      #   account: the person's account
      class Pulled < Trailblazer::Cell
        alias result model

        private

        def account
          result['account']
        end

        def email
          account.email
        end

        def link_to_go_back
          link_to "Back to this person's main page", admin_person_path(person)
        end

        def person
          result['person']
        end

        def person_first_name
          person.first_name
        end

        def table_rows
          cell(TableRow, collection: result['collection'])
        end

        # model: a CardRecommendation
        class TableRow < Trailblazer::Cell
          property :applied_at
          property :clicked_at
          property :declined_at
          property :denied_at
          property :pulled_at
          property :recommended_at
          property :seen_at

          private

          def tr_tag(&block)
            content_tag(
              :tr,
              id: dom_id(model),
              class: dom_class(model),
              &block
            )
          end

          def product
            model.product
          end

          def product_name
            product.name
          end

          def product_identifier
            cell(CardProduct::Cell::Identifier, product)
          end

          %i[
            recommended_at seen_at clicked_at applied_at denied_at declined_at
            pulled_at
          ].each do |date_attr|
            define_method date_attr do
              super()&.strftime('%D') || '-' # 12/01/2015
            end
          end
        end
      end
    end
  end
end
