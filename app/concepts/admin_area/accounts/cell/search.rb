module AdminArea
  module Accounts
    module Cell
      class Search < Abroaders::Cell::Base
        extend Abroaders::Cell::Result
        include Kaminari::Cells
        include Escaped

        skill :collection

        def title
          'Accounts Search Results'
        end

        private

        def page
          options[:page] || 1
        end

        def paginated_accounts
          @paginated_accounts ||= collection.page(page).per(50)
        end

        def paginator
          paginate(paginated_accounts)
        end

        def query
          escape!(result['query'])
        end

        def table_rows
          cell(AdminArea::Accounts::Cell::Index::TableRow, collection: paginated_accounts)
        end
      end
    end
  end
end
