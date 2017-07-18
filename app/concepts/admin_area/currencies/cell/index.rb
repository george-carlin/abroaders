module AdminArea::Currencies
  module Cell
    # model: Collection<Currency>
    class Index < Abroaders::Cell::Base
      include Escaped

      def title
        'Currencies'
      end
    end
  end
end
