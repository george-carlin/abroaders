module AdminArea::Offers
  module Cell
    # Takes a list of offers, assumed to be the 'alternatives' for another
    # offer (see docs for `AlternativesFor` for the definition of what an
    # alternative is), and returns a <table> that lists those offers.
    #
    # @!method self.call(offers)
    #   @param offers [Collection<Offer>]
    class AlternativesTable < Abroaders::Cell::Base
      private

      def table_rows
        cell(Row, collection: model)
      end

      class Row < Abroaders::Cell::Base
        property :id
        property :cost
        property :last_reviewed_at
        property :link
        property :partner
        property :value

        private

        def conditions
          cell(AdminArea::Offers::Cell::Identifier, model)
        end

        def cost
          number_to_currency(super)
        end

        def id_with_link_to_show
          link_to id, admin_offer_path(model)
        end

        def last_reviewed_at
          super ? super.strftime('%m/%d/%Y') : 'never'
        end

        def link_to_url
          link_to 'URL', link, target: '_blank'
        end

        def partner
          cell(Partner::Cell::FullName, super)
        end

        # 'unresolved' recs & 'active' recs = same thing
        def unresolved_recs_count
          # We should probably add a counter cache column for this:
          model.unresolved_recommendations.size
        end

        def value
          super ? number_to_currency(super) : 'Unknown'
        end
      end

      # Takes an offer, and returns a section displaying a <table> of the
      # offer's alternatives, if there are any, or some text saying that there
      # are no alternatives, and in either case with a header.
      #
      # @!method self.call(offer)
      #   @param offer [Offer]
      class Section < Abroaders::Cell::Base
        def show
          body = if alternatives.any?
                   cell(AlternativesTable, alternatives)
                 else
                   "No alternatives found"
                 end
          "#{header}#{body}"
        end

        private

        def alternatives
          @alternatives ||= AlternativesFor.(model)
        end

        def header
          text = 'Alternatives'
          text << " (#{alternatives.count})" if alternatives.any?
          "<h4>#{text}</h4>"
        end
      end
    end
  end
end
