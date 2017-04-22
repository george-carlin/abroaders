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

      def table_rows
        cell(Row, collection: visible_recommendations)
      end

      def table_tag(&block)
        content_tag(
          :table,
          class: 'table table-striped tablesorter',
          id: 'admin_person_card_recommendations_table',
          &block
        )
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

      class Row < Abroaders::Cell::Base
        include Escaped

        # @param recommendation [Card] must be a recommendation
        def initialize(rec, options = {})
          super(CardRecommendation.new(rec), options)
        end

        property :id
        property :applied_on
        property :clicked_at
        property :decline_reason
        property :declined?
        property :declined_at
        property :card_product
        property :recommended_at
        property :seen_at
        property :status

        private

        def card_product_name
          cell(CardProduct::Cell::FullName, card_product, with_bank: true)
        end

        %i[
          recommended_at seen_at clicked_at denied_at declined_at applied_on
        ].each do |date_attr|
          define_method date_attr do
            super()&.strftime('%D') || '-' # 12/01/2015
          end
        end

        # If the card was opened/closed after being recommended by an admin,
        # we know the exact date it was opened closed. If they added the card
        # themselves (e.g. when onboarding), they only provide the month
        # and year, and we save the date as the 1st of thet month.  So if the
        # card was added as a recommendation, show the the full date, otherwise
        # show e.g.  "Jan 2016". If the date is blank, show '-'
        #
        # TODO rethink how we know whether a card was added in the survey
        %i[closed_on opened_on].each do |date_attr|
          define_method date_attr do
            # if model.recommended_at.nil? # if card is not a recommendation
            # super()&.strftime('%b %Y') || '-' # Dec 2015
            # else
            super()&.strftime('%D') || '-' # 12/01/2015
            # end
          end
        end

        def tr_tag(&block)
          content_tag(
            :tr,
            id: "card_recommendation_#{id}",
            class: 'card_recommendation',
            'data-bp':       card_product.bp,
            'data-bank':     card_product.bank_id,
            'data-currency': card_product.currency_id,
            &block
          )
        end

        def status
          Inflecto.humanize(super)
        end

        def decline_reason_tooltip
          return '' unless model.declined?
          link_to('#', 'data-toggle': 'tooltip', title: decline_reason) do
            fa_icon('question')
          end
        end

        def link_to_delete
          link_to(
            'Del',
            admin_card_recommendation_path(model),
            data: {
              confirm: 'Are you sure you want to delete this recommendation?',
              method: :delete,
            },
          )
        end

        def link_to_edit
          link_to 'Edit', edit_admin_card_recommendation_path(model)
        end
      end
    end
  end
end
