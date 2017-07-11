module AdminArea::Offers
  module Cell
    # Takes an offer and returns a <table> listing that offer's 'alternatives'
    # (see docs for `AlternativesFor`). Returns an empty string if offer has no
    # alternatives.
    #
    # @!method self.call(offer)
    #   @param alternative_offers [Collection<Offer>]
    class AlternativesTable < Abroaders::Cell::Base
      property :id

      def show
        return '' unless show?
        super
      end

      def show?
        alternatives.any?
      end

      private

      def alternatives
        @alternatives ||= AlternativesFor.(model)
      end

      def html_id
        "offer_#{id}_alternatives_table"
      end

      def table_rows
        cell(Row, collection: alternatives)
      end

      class Row < Abroaders::Cell::Base
        property :id
        property :cost
        property :last_reviewed_at
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
          cell(LastReviewedAt, model)
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

      # Like AlternativesTable, but with a header tag, and if approporiate
      # tells the user that no alternatives were found/
      #
      # @!method self.call(offer)
      #   @param alternative_offers [Collection<Offer>]
      class Section < Abroaders::Cell::Base
        def show
          result = "<h4>Alternatives</h4>"
          result << if (table = cell(AlternativesTable, model)).show?
                      table.to_s
                    else
                      "No alternatives found"
                    end
        end

        private

        def header
          "<h4>Alternatives</h4>"
        end
      end
    end
  end
end
