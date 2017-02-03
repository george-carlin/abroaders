class Currency < ApplicationRecord
  module Cell
    class ShortName < Trailblazer::Cell
      property :name

      # "Bank of America (Americard Points)" => "Bank of America"
      def show
        # FIXME really this should be the other way around: 'Bank of America' and
        # 'Americard Points' should be 2 separate columns which we join, not split,
        # in the view
        name.sub(/\s+\(.*\)\s*/, '')
      end
    end
  end
end
