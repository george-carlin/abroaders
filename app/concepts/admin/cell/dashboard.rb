class Admin < Admin.superclass
  module Cell
    class Dashboard < Abroaders::Cell::Base
      def title
        'Admin Dashboard'
      end
    end
  end
end
