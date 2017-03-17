module AdminArea
  module Offers
    module Cell
      # Takes an Offer. If the offer has never been reviewed by an Admin,
      # returns 'never'. If it has, returns the date of the last review in the
      # format 'MM/DD/YYYY'
      class LastReviewedAt < Abroaders::Cell::Base
        def show
          date = model.last_reviewed_at
          date.nil? ? 'never' : date.strftime('%m/%d/%Y')
        end
      end
    end
  end
end
