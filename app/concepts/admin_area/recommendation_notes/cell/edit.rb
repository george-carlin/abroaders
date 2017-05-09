module AdminArea
  module RecommendationNotes
    module Cell
      class Edit < Abroaders::Cell::Base
        include Escaped

        property :account

        option :form
      end
    end
  end
end
