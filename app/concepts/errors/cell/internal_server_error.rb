module Errors
  module Cell
    class InternalServerError < Abroaders::Cell::Base
      def title
        'Error'
      end
    end
  end
end
