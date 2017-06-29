module AdminArea
  module Destinations
    module Cell
      class Index < Abroaders::Cell::Base
        include Kaminari::Cells

        option :page_type

        def title
          page_type.pluralize.capitalize
        end

        private

        def all_destinations?
          page_type == 'destination'
        end

        def page
          options[:page] || 1
        end

        def paginated_accounts
          @paginated_accounts ||= model.page(page).per_page(50)
        end

        def paginator
          paginate(model)
        end

        def table_rows
          cell(TableRow, collection: model, page_type: page_type)
        end

        class TableRow < Abroaders::Cell::Base
          include Escaped

          property :code
          property :name
          property :parent_name
          property :type

          option :page_type

          private

          def type
            super.to_s.capitalize
          end
        end
      end
    end
  end
end
