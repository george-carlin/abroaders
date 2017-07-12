module AdminArea::People::Cell
  class Show < Show.superclass
    # Takes the person, shows their card recommendations. Has a header that
    # says 'Recommendation' and a link to add a new rec for the person. If the
    # person has any recs, they'll be shown in a <table>. If they don't have
    # any, the table will still be rendered, but hidden with CSS (to be shown
    # by JS if the admin makes a recommendation), and there'll be a <p> that
    # tells you there's no recs.
    #
    # @!method self.call(person, options = {})
    #   @param person [Person] make sure that card_accounts => card_product => bank
    #     is eager-loaded.
    class CardRecommendations < Abroaders::Cell::Base
      property :card_recommendations

      private

      def table
        id = 'admin_person_card_recommendations_table'
        cell_class = AdminArea::CardRecommendations::Cell::Table
        cell(cell_class, visible_recommendations, html_id: id)
      end

      def wrapper(&block)
        # Always output the table onto the page, but hide it with CSS if there
        # are no recs. It will be shown later by JS if the admin makes a rec.
        content_tag(
          :div,
          id: 'admin_person_card_recommendations',
          class: 'admin_person_card_recommendations',
          style: visible_recommendations.any? ? '' : 'display:none;',
          &block
        )
      end

      def visible_recommendations
        @_vr ||= card_recommendations.reject(&:opened?)
      end
    end
  end
end
