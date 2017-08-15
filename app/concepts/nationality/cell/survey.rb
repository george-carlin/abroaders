module Nationality
  module Cell
    class Survey < Abroaders::Cell::Base
      def title
        'Are You Eligible?'
      end

      private

      def buttons
        cell(Buttons, model)
      end

      class Buttons < Abroaders::Cell::Base
        include Escaped

        property :companion_first_name
        property :couples?
        property :owner_first_name

        private

        def couples_h
          {
            both: "Both #{owner_first_name} and #{companion_first_name} are U.S. citizens or permanent residents.",
            owner: "Only #{owner_first_name} is a U.S. citizen or permanent resident.",
            companion: "Only #{companion_first_name} is a U.S. citizen or permanent resident.",
            neither:  "Neither of us is a U.S. citizen or permanent resident.",
          }
        end
      end
    end
  end
end
