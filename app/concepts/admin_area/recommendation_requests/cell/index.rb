module AdminArea::RecommendationRequests
  module Cell
    class Index < Abroaders::Cell::Base
      def title
        'Unresolved Rec Requests'
      end

      private

      def rows
        cell(Row, collection: model)
      end

      class Row < Abroaders::Cell::Base
        property :companion
        property :email
        property :id
        property :owner

        private

        def person_cell(person)
          cell(PersonCell, person)
        end

        class PersonCell < Abroaders::Cell::Base
          include Escaped

          property :first_name
          property :unresolved_recommendation_request
          property :unresolved_recommendation_request?

          def show
            return '<td>None</td>' if model.nil? # i.e. for a nil companion
            link_to_name = link_to first_name, admin_person_path(model)
            content = if unresolved_recommendation_request?
                        req = unresolved_recommendation_request
                        date = req.created_at.strftime('%D')
                        "#{link_to_name} - requested #{date}"
                      else
                        "#{link_to_name} - no request"
                      end
            "<td>#{content}</td>"
          end
        end
      end
    end
  end
end
