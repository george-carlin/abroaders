module Errors
  module Cell
    class NotFound < Abroaders::Cell::Base
      def title
        'Page Not Found'
      end
    end
  end
end
