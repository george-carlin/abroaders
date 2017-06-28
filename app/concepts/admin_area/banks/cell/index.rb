module AdminArea::Banks
  module Cell
    # @!method self.call(banks, options = {})
    class Index < Abroaders::Cell::Base
      def title
        'Banks'
      end

      private

      def table_rows
        cell(TableRow, collection: model)
      end

      class TableRow < Abroaders::Cell::Base
        include Escaped

        property :business_phone
        property :name
        property :personal_phone

        def show
          <<-HTML
            <tr>
              <td>#{name}</td>
              <td>#{personal_phone}</td>
              <td>#{business_phone}</td>
            </tr>
          HTML
        end
      end
    end
  end
end
