module AdminArea
  module Accounts
    module Cell
      class Search < Abroaders::Cell::Base
        extend Abroaders::Cell::Result

        skill :collection

        def title
          'Accounts Search Results'
        end

        private

        def query
          escape(result['query'])
        end

        def table_rows
          cell(AdminArea::Accounts::Cell::Index::TableRow, collection: collection)
        end
      end
    end
  end
end
