module AdminArea
  module Accounts
    module Cell
      # model: array of Accounts
      class Search < Abroaders::Cell::Base
        include Kaminari::Cells
        include Escaped

        def title
          'Accounts Search Results'
        end

        private

        def page
          options[:page] || 1
        end

        def paginated_accounts
          @paginated_accounts ||= model.page(page).per(50)
        end

        def paginator
          paginate(paginated_accounts)
        end

        def query
          escape!(options.fetch(:query))
        end

        def table_rows
          cell(Index::TableRow, collection: paginated_accounts)
        end
      end
    end
  end
end
