module AdminArea
  module Accounts
    module Cell
      class Search < Trailblazer::Cell
        extend Abroaders::Cell::Result

        skill :collection

        def title
          'Accounts Search Results'
        end

        private

        def query
          ERB::Util.html_escape(result['query'])
        end

        def table_rows
          cell(AdminArea::Accounts::Cell::Index::TableRow, collection: collection)
        end
      end
    end
  end
end
