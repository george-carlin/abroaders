class RecommendationRequest < RecommendationRequest.superclass
  module Cell
    class Banner < Banner.superclass
      # TODO not yet implemented
      #
      # Text that appears at the top of most pages (above the 'request a rec'
      # button if that button is visible). If any eligible user on the account
      # has an unconfirmed recommendation request (i.e. they clicked 'request a
      # rec' but didn't finish the confirmation survey), this cell will remind
      # them about it and have a link to finish the survey.
      #
      # If they have recommendations that they need respond to, I might tell
      # them about it here as well. Still undecided if this is the right place
      # to do it.
      #
      # @!method self.call(account, options = {})
      class Status < Abroaders::Cell::Base
        def show # placeholder
          ''
        end
      end
    end
  end
end
